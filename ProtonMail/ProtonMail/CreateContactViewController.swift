//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import UIKit

class CreateContactViewController: ProtonMailViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    private let kInvalidEmailShakeTimes: Float = 3.0
    private let kInvalidEmailShakeOffset: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITextField.appearance().tintColor = UIColor.ProtonMail.Gray_999DA1
        
        nameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    @IBAction func didTapCancelButton(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapSaveButton(sender: UIBarButtonItem) {
        
        if (!emailTextField.text.isValidEmail()) {
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.layer.borderWidth = 0.5
            emailTextField.shake(kInvalidEmailShakeTimes, offset: kInvalidEmailShakeOffset)
        }
        
        println("Saving a new contact: Name: \(nameTextField.text) and email: \(emailTextField.text)")
    }
    
    override func shouldShowSideMenu() -> Bool {
        return false
    }
}

extension CreateContactViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == nameTextField) {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        }
        
        if (textField == emailTextField) {
            emailTextField.resignFirstResponder()
        }
        
        return true
    }
}