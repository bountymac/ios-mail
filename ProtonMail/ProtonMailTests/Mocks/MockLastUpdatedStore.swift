//
//  MockLastUpdatedStore.swift
//  ProtonMailTests
//
//  Copyright (c) 2021 Proton Technologies AG
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
import PromiseKit
import CoreData
import ProtonCore_DataModel
@testable import ProtonMail

class MockLastUpdatedStore: LastUpdatedStoreProtocol {
    var contactsCached: Int = 0
    var msgUnreadData: [String: Int] = [:] //[LabelID: UnreadCount]
    var conversationUnreadData: [String: Int] = [:] //[LabelID: UnreadCount]
    var msgLabelUpdate: [String: LabelUpdate] = [:] //[LabelID: LabelUpdate]
    var conversationLabelUpdate: [String: ConversationCount] = [:] //[LabelID: ConversationCount]

    var testContext: NSManagedObjectContext?
    
    static func clear() {
        
    }
    
    static func cleanUpAll() -> Promise<Void> {
        return Promise<Void>()
    }
    
    func clear() {
        
    }
    
    func cleanUp(userId: String) -> Promise<Void> {
        return Promise<Void>()
    }
    
    func resetUnreadCounts() {
        self.msgUnreadData.removeAll()
        self.conversationUnreadData.removeAll()
    }
    
    func updateEventID(by userID: String, eventID: String) -> Promise<Void> {
        return Promise<Void>()
    }
    
    func lastEventID(userID: String) -> String {
        return ""
    }
    
    func lastEvent(userID: String, context: NSManagedObjectContext) -> UserEvent {
        return UserEvent(context: context)
    }
    
    func lastEventUpdateTime(userID: String) -> Date? {
        return nil
    }
    
    func lastUpdate(by labelID: String, userID: String, context: NSManagedObjectContext, type: ViewMode) -> LabelCount? {
        switch type {
        case .singleMessage:
            return self.msgLabelUpdate[labelID]
        case .conversation:
            return self.conversationLabelUpdate[labelID]
        }
    }
    
    func lastUpdateDefault(by labelID: String, userID: String, context: NSManagedObjectContext, type: ViewMode) -> LabelCount {
        switch type {
        case .singleMessage:
            if let data = self.msgLabelUpdate[labelID] {
                return data
            } else {
                let newData = LabelUpdate.newLabelUpdate(by: labelID, userID: userID, inManagedObjectContext: context)
                self.msgLabelUpdate[labelID] = newData
                return newData
            }
        case .conversation:
            if let data = self.conversationLabelUpdate[labelID] {
                return data
            } else {
                let newData = ConversationCount.newConversationCount(by: labelID, userID: userID, inManagedObjectContext: context)
                self.conversationLabelUpdate[labelID] = newData
                return newData
            }
        }
    }
    
    func unreadCount(by labelID: String, userID: String, type: ViewMode) -> Promise<Int> {
        var count = 0
        switch type {
        case .singleMessage:
            count = Int(self.msgLabelUpdate[labelID]?.unread ?? 0)
        case .conversation:
            count = Int(self.conversationLabelUpdate[labelID]?.unread ?? 0)
        }
        return Promise.value(count)
    }
    
    func unreadCount(by labelID: String, userID: String, type: ViewMode) -> Int {
        switch type {
        case .singleMessage:
            return Int(self.msgLabelUpdate[labelID]?.unread ?? 0)
        case .conversation:
            return Int(self.conversationLabelUpdate[labelID]?.unread ?? 0)
        }
    }
    
    func updateUnreadCount(by labelID: String, userID: String, count: Int, type: ViewMode, shouldSave: Bool) {
        switch type {
        case .singleMessage:
            if let data = self.msgLabelUpdate[labelID] {
                data.unread = Int32(count)
            } else {
                let newData = LabelUpdate.newLabelUpdate(by: labelID, userID: userID, inManagedObjectContext: testContext!)
                newData.unread = Int32(count)
                self.msgLabelUpdate[labelID] = newData
            }
        case .conversation:
            if let data = self.conversationLabelUpdate[labelID] {
                data.unread = Int32(count)
            } else {
                let newData = ConversationCount.newConversationCount(by: labelID, userID: userID, inManagedObjectContext: testContext!)
                newData.unread = Int32(count)
                self.conversationLabelUpdate[labelID] = newData
            }
        }
    }
    
    func removeUpdateTime(by userID: String, type: ViewMode) {
        
    }

    func removeUpdateTimeExceptUnread(by userID: String, type: ViewMode) {
        
    }

    func lastUpdates(by labelIDs: [String], userID: String, context: NSManagedObjectContext, type: ViewMode) -> [LabelCount] {
        return []
    }

    func getUnreadCounts(by labelID: [String], userID: String, type: ViewMode) -> Promise<[String: Int]> {
        return Promise<[String: Int]>.value([:])
    }
}
