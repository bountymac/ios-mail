//
//  UnlockManager.swift
//  ProtonMail - Created on 02/11/2018.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation
import Keymaker
import LocalAuthentication


enum SignInUIFlow : Int {
    case requirePin = 0
    case requireTouchID = 1
    case restore = 2
}

protocol CacheStatusInject {
    var isPinCodeEnabled : Bool { get }
    var isTouchIDEnabled : Bool { get }
    var pinFailedCount : Int { get set }
}

protocol UnlockManagerDelegate : class {
    func cleanAll()
    func unlocked()
    
    var isUserCredentialStored : Bool { get }
    func isMailboxPasswordStored(forUser uid: String?) -> Bool
}

class UnlockManager: Service {
    var cacheStatus : CacheStatusInject
    weak var delegate : UnlockManagerDelegate?
    
    static var shared: UnlockManager {
        #if !APP_EXTENSION
        return sharedServices.get(by: UnlockManager.self)
        #else
        fatalError("FIXME")
        #endif
    }
    
    init(cacheStatus: CacheStatusInject, delegate: UnlockManagerDelegate?) {
        self.cacheStatus = cacheStatus
        self.delegate = delegate
    }
    
    internal func isUnlocked() -> Bool {
        return self.validate(mainKey: keymaker.mainKey)
    }
    
    internal func getUnlockFlow() -> SignInUIFlow {
        if cacheStatus.isPinCodeEnabled {
            return SignInUIFlow.requirePin
        }
        if cacheStatus.isTouchIDEnabled {
            return SignInUIFlow.requireTouchID
        }
        return SignInUIFlow.restore
    }
    
    internal func match(userInputPin: String, completion: @escaping (Bool)->Void) {
        guard !userInputPin.isEmpty else {
            cacheStatus.pinFailedCount += 1
            completion(false)
            return
        }
        keymaker.obtainMainKey(with: PinProtection(pin: userInputPin)) { key in
            guard self.validate(mainKey: key) else {
                userCachedStatus.pinFailedCount += 1
                completion(false)
                return
            }
            self.cacheStatus.pinFailedCount = 0;
            completion(true)
        }
    }
    
    private func validate(mainKey: Keymaker.Key?) -> Bool {
        guard let _ = mainKey else { // currently enough: key is Array and will be nil in case it was unlocked incorrectly
            keymaker.lockTheApp() // remember to remove invalid key in case validation will become more complex
            return false
        }
        return true
    }
    
    
    internal func biometricAuthentication(requestMailboxPassword: @escaping ()->Void) {
        self.biometricAuthentication(afterBioAuthPassed: { self.unlockIfRememberedCredentials(requestMailboxPassword: requestMailboxPassword) })
    }
    
    var isRequestingBiometricAuthentication: Bool = false
    internal func biometricAuthentication(afterBioAuthPassed: @escaping ()->Void) {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            PMLog.D("LAContext canEvaluatePolicy is false, error: " + String(describing: error?.localizedDescription))
            assert(false, "LAContext canEvaluatePolicy is false")
            return
        }
        
        guard !self.isRequestingBiometricAuthentication else { return }
        self.isRequestingBiometricAuthentication = true
        keymaker.obtainMainKey(with: BioProtection()) { key in
            defer {
                self.isRequestingBiometricAuthentication = false
            }
            guard self.validate(mainKey: key) else { return }
            afterBioAuthPassed()
        }
    }
    
    internal func initiateUnlock(flow signinFlow: SignInUIFlow,
                                 requestPin: @escaping ()->Void,
                                 requestMailboxPassword: @escaping ()->Void)
    {
        switch signinFlow {
        case .requirePin:
            requestPin()

        case .requireTouchID:
            self.biometricAuthentication(requestMailboxPassword: requestMailboxPassword) // will send message
            
        case .restore:
            self.unlockIfRememberedCredentials(requestMailboxPassword: requestMailboxPassword)
        }
    }
    
    internal func unlockIfRememberedCredentials(forUser uid: String? = nil,
                                                requestMailboxPassword: ()->Void) {
        guard keymaker.mainKeyExists(), self.delegate?.isUserCredentialStored == true else {
            self.delegate?.cleanAll()
            return
        }
        
        guard self.delegate?.isMailboxPasswordStored(forUser: uid) == true else { // this will provoke mainKey obtention
            requestMailboxPassword()
            return
        }

        cacheStatus.pinFailedCount = 0
        
        #if !APP_EXTENSION
        UserTempCachedStatus.clearFromKeychain()
        sharedServices.get(by: UsersManager.self).users.forEach {
            $0.messageService.injectTransientValuesIntoMessages()
            self.updateUserData(of: $0)
        }
        self.updateCommonUserData()
        StoreKitManager.default.processAllTransactions()
        #endif
        
        NotificationCenter.default.post(name: Notification.Name.didUnlock, object: nil) // needed for app unlock
        NotificationCenter.default.post(name: Notification.Name.didObtainMailboxPassword, object: nil) // needed by 2-password mode AccountConnectViewController
    }
    
    
    #if !APP_EXTENSION
    // TODO: verify if some of these operations can be optimized
    private func updateUserData(of user: UserManager) { // previously this method was called loadContactsAfterInstall()
        user.sevicePlanService.updateServicePlans()
        user.sevicePlanService.updateCurrentSubscription()
    }
    
    func updateCommonUserData() {
//        sharedUserDataService.fetchUserInfo().done { _ in }.catch { _ in }
//        //TODO:: here need to be changed
//        sharedContactDataService.fetchContacts { (contacts, error) in
//            if error != nil {
//                PMLog.D("\(String(describing: error))")
//            } else {
//                PMLog.D("Contacts count: \(contacts?.count)")
//            }
//        }
    }
    #endif
}
