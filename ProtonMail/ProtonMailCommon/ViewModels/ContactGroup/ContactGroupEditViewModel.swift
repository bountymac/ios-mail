//
//  ContactGroupEditViewModel.swift
//  ProtonMail
//
//  Created by Chun-Hung Tseng on 2018/8/21.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import Foundation

protocol ContactGroupEditViewModelDelegate {
    func update()
}

enum ContactGroupTableCellType
{
    case selectColor
    case manageContact
    case email
    case deleteGroup
    case error
}

protocol ContactGroupEditViewModel {
    // delegate
    var delegate: ContactGroupEditViewModelDelegate! { get set }
    
    // get operations
    func getViewTitle() -> String
    func getContactGroupName() -> String
    func getContactGroupID() -> String
    
    // fetch operations
    func getCurrentColorWithDefault() -> String
    func getEmailIDsInContactGroup() -> NSSet
    
    // mutate operations
    func addEmailsToContactGroup(emailList: NSSet)
    func removeEmailsFromContactGroup(emailList: NSSet)
    func updateColor(newColor: String?)
    
    // create and edit
    func saveContactGroupDetail(name: String, color: String, emailList: NSSet)

    // delete
    func deleteContactGroup()
    
    // table operation
    func getTotalSections() -> Int
    func getTotalRows(for section: Int) -> Int
    func getCellType(at indexPath: IndexPath) -> ContactGroupTableCellType
    func getEmail(at indexPath: IndexPath) -> (String, String)
}
