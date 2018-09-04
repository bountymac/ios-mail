//
//  ServicePlan.swift
//  ProtonMail
//
//  Created by Anatoly Rosencrantz on 20/08/2018.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import Foundation

enum ServicePlan: String {
    case free = "free"
    case plus = "plus"
    case pro = "professional"
    case visionary = "visionary"
    
    internal func fetchDetails() -> ServicePlanDetails? {
        return ServicePlanDataService.shared.detailsOfServicePlan(named: self.rawValue)
    }
    
    // FIXME: localization
    internal var subheader: (String, UIColor) {
        switch self {
        case .free: return ("Free", UIColor.ProtonMail.ServicePlanFree)
        case .plus: return ("Plus", UIColor.ProtonMail.ServicePlanPlus)
        case .pro: return ("Professional", UIColor.ProtonMail.ServicePlanPro)
        case .visionary: return ("Visionary", UIColor.ProtonMail.ServicePlanVisionary)
        }
    }
    
    // FIXME: localization
    internal var headerText: String {
        switch self {
        case .free: return LocalString._free_header
        case .plus: return LocalString._plus_header
        case .pro: return LocalString._pro_header
        case .visionary: return LocalString._vis_header
        }
    }
    
    internal var storeKitProductId: String? {
        switch self {
        case .free, .pro, .visionary: return nil
        case .plus: return "ios_plus_12_usd_consumable"
        }
    }
    
    internal init?(storeKitProductId: String) {
        guard storeKitProductId == ServicePlan.plus.storeKitProductId else {
            return nil
        }
        self = .plus
    }
}
