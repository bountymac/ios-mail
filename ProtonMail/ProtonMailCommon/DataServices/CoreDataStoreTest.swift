//
//  CoreDataStoreTest.swift
//  ProtonMail - Created on 12/19/18.
//
//
//  The MIT License
//
//  Copyright (c) 2018 Proton Technologies AG
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
    

import XCTest
@testable import ProtonMail
import CoreData
import Groot

class CoreDataStoreTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //
        // Generate test data
        //
        let oldModelUrl = Bundle.main.url(forResource: "ProtonMail.momd/ProtonMail", withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelUrl)
        XCTAssertNotNil(oldManagedObjectModel)
        
        let coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: oldManagedObjectModel!)
        let url = FileManager.default.temporaryDirectoryUrl.appendingPathComponent("ProtonMail.sqlite", isDirectory: false)
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        XCTAssertNotNil(managedObjectContext)
        
        
        let test = """
 {
    "IsForwarded" : 0,
    "IsEncrypted" : 1,
    "ExpirationTime" : 0,
    "ReplyTo" : {
        "Address" : "contact@protonmail.ch",
        "Name" : "ProtonMail"
    },
    "Subject" : "Important phishing warning for all ProtonMail users",
    "BCCList" : [
    ],
    "Size" : 2217,
    "ParsedHeaders" : {
        "Subject" : "Important phishing warning for all ProtonMail users",
        "X-Pm-Content-Encryption" : "end-to-end",
        "To" : "feng88@protonmail.com",
        "X-Auto-Response-Suppress" : "OOF",
        "Precedence" : "bulk",
        "X-Original-To" : "feng88@protonmail.com",
        "Mime-Version" : "1.0",
        "Return-Path" : "<contact@protonmail.ch>",
        "Content-Type" : "texthtml",
        "Delivered-To" : "feng88@protonmail.com",
        "From" : "ProtonMail <contact@protonmail.ch>",
        "Received" : "from mail.protonmail.ch by mail.protonmail.ch; Wed, 02 May 2018 12:43:19 -0400",
        "Message-Id" : "<MQV54A1N98S8ASTB7Z183NM1MG@protonmail.ch>",
        "Date" : "Wed, 02 May 2018 12:43:19 -0400",
        "X-Pm-Origin" : "internal"
    },
    "ToList" : [
    {
    "Address" : "feng88@protonmail.com",
    "Name" : "",
    "Group" : ""
    }
    ],
    "Order" : 200441873160,
    "IsRepliedAll" : 0,
    "ExternalID" : "MQV54A1N98S8ASTB7Z183NM1MG@protonmail.ch",
    "AddressID" : "hbBwBsOdTi5cDhhZcF28yrJ50AZQ8jhXF4d0P7OaUcCS5iv2N8hN_FjvAyPMt8EiP5ch_E_81gHZAjK4D3gfzw==",
    "Location" : 0,
    "LabelIDs" : [
    "0",
    "5",
    "10"
    ],
    "Time" : 1525279399,
    "ReplyTos" : [
    {
    "Address" : "contact@protonmail.ch",
    "Name" : "ProtonMail"
    }
    ],
    "NumAttachments" : 0,
    "SenderAddress" : "contact@protonmail.ch",
    "MIMEType" : "texthtml",
    "Starred" : 1,
    "Unread" : 0,
    "ID" : "cA6j2rszbPUSnKojxhGlLX2U74ibyCXc3-zUAb_nBQ5UwkYSAhoBcZag8Wa0F_y_X5C9k9fQnbHAITfDd_au1Q==",
    "ConversationID" : "3Spjf96LXv8EDUylCxJkKsL7x9IgBac_0z416buSBBMwAkbh_dHh2Ng7O6ss70yhlaLBht0hiJqvqbxoBKtb9Q==",
    "Body" : "-----BEGIN PGP MESSAGE-----This is encrypted body-----END PGP MESSAGE-----",
    "Flags" : 13,
    "Header" : "Date: Wed, 02 May 2018 12:43:19 this is a header",
    "SenderName" : "ProtonMail",
    "SpamScore" : 0,
    "Attachments" : [
    ],
    "Type" : 0,
    "CCList" : [
    ],
    "Sender" : {
        "Address" : "contact@protonmail.ch",
        "Name" : "ProtonMail"
    },
    "IsReplied" : 0
}
"""
        guard let out = test.parseObjectAny() else {
            return
        }

        let managedObj = try? GRTJSONSerialization.object(withEntityName: "Message",
                                                         fromJSONDictionary: out, in: managedObjectContext)
        //NSEntityDescription.insertNewObjectForEntityForName
        XCTAssertNotNil(managedObj)
        
        //build samples
    }

    override func tearDown() {
        //clear out the data
        do {
            let url = FileManager.default.temporaryDirectoryUrl.appendingPathComponent("ProtonMail.sqlite", isDirectory: false)
            try FileManager.default.removeItem(at: url)
        } catch {
            XCTAssertNotNil(nil)
        }
        
        do {
            let url = FileManager.default.temporaryDirectoryUrl.appendingPathComponent("ProtonMail_NewModel.sqlite", isDirectory: false)
            try FileManager.default.removeItem(at: url)
        } catch {
            XCTAssertNotNil(nil)
        }
    }

    func test_ProtonMail_to_1_12_0() {
        let oldModelUrl = Bundle.main.url(forResource: "ProtonMail.momd/ProtonMail", withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelUrl)
        let oldUrl = FileManager.default.temporaryDirectoryUrl.appendingPathComponent("ProtonMail.sqlite", isDirectory: false)
        XCTAssertNotNil(oldManagedObjectModel)
        //
        // Migration
        //
        let newModelUrl = Bundle.main.url(forResource: "ProtonMail.momd/1.12.0", withExtension: "mom")!
        let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelUrl)
        let newUrl = FileManager.default.temporaryDirectoryUrl.appendingPathComponent("ProtonMail_NewModel.sqlite", isDirectory: false)
        XCTAssertNotNil(newManagedObjectModel)
        
//        NSMappingModel.entityMappingsByName
        
        let mappingUrl = Bundle.main.url(forResource: "ProtonMail_to_1.12.0", withExtension: "cdm")!
        //NSMappingModel *mappingModel = [[NSMappingModel alloc] initWithContentsOfURL:fileURL]
        let mappingModel = NSMappingModel(contentsOf: mappingUrl) //NSMappingModel(from: [CoreDataStore.modelBundle], forSourceModel: oldManagedObjectModel, destinationModel: newManagedObjectModel)
        XCTAssertNotNil(mappingModel)
        let migrationManager = NSMigrationManager(sourceModel: oldManagedObjectModel!, destinationModel: newManagedObjectModel!)
        XCTAssertNotNil(migrationManager)
        //Migrate type in the future could try to user in memory Type
        do {
            try migrationManager.migrateStore(from: oldUrl,
                                              sourceType: NSSQLiteStoreType,
                                              options: nil,
                                              with: mappingModel,
                                              toDestinationURL: newUrl,
                                              destinationType: NSSQLiteStoreType,
                                              destinationOptions: nil)
        } catch {
            print("Error: \(error)")
            XCTAssertNil(error)
        }
        

        //
        // to verify data
        //
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
