//
//  ContactVOExtension.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 6/21/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation





extension ContactVO {
    
    
    /**
    ContactVO extension for check is contactVO contained by a Array<Address>

    :param: addresses check addresses
    
    :returns: true | false
    */
    func isDuplicated(addresses : Array<Address>) -> Bool
    {
        if let found = find(addresses.map({ $0.email }), self.email) {
            return true
        }
        return false
    }
}
