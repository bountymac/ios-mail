//
//  ReportTests.swift
//  ProtonMailUITests
//
//  Created by mirage chung on 2020/12/11.
//  Copyright © 2020 Proton Mail. All rights reserved.
//

import XCTest

import ProtonCore_TestingToolkit

class ReportTests: BaseTestCase {
    
    func testEditAndSendBugReport() {
        let user = users["plus"]!
        let topic = "This is an automation test bug report"
        
        LoginRobot()
            .loginUser(user)
            .menuDrawer()
            .reports()
            .sendBugReport(topic)
    }
}
