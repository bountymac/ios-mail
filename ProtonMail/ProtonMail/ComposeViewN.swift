//
//  ComposeViewN.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 5/27/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//
import Foundation
import UIKit



protocol ComposeViewNDelegate {
    func ComposeViewNDidSizeChanged(size: CGSize)
    func composeViewDidTapNextButton(composeView: ComposeViewN)
    func composeViewDidTapEncryptedButton(composeView: ComposeViewN)
    
//        func composeViewDidTapAttachmentButton(composeView: ComposeViewN)
//        func composeView(composeView: ComposeViewN, didAddContact contact: ContactVO, toPicker picker: MBContactPicker)
//        func composeView(composeView: ComposeViewN, didRemoveContact contact: ContactVO, fromPicker picker: MBContactPicker)

}

protocol ComposeViewNDataSource {
    func composeViewContactsModelForPicker(composeView: ComposeViewN, picker: MBContactPicker) -> [AnyObject]!
    func composeViewSelectedContactsForPicker(composeView: ComposeViewN, picker: MBContactPicker) -> [AnyObject]!
}



class ComposeViewN: UIViewController {
    
    var toContactPicker: MBContactPicker!
    var toContacts: String {
        return toContactPicker.contactList
    }
    var ccContactPicker: MBContactPicker!
    var ccContacts: String {
        return ccContactPicker.contactList
    }
    var bccContactPicker: MBContactPicker!
    var bccContacts: String {
        return bccContactPicker.contactList
    }
    
    
    var expirationTimeInterval: NSTimeInterval = 0
    
    var hasContent: Bool {//need check body also here
        return !toContacts.isEmpty || !ccContacts.isEmpty || !bccContacts.isEmpty || !subjectTitle.isEmpty
    }
    
    var subjectTitle: String {
        return subject.text ?? ""
    }
    
    // MARK : - HtmlEditor
    public var htmlEditor : HtmlEditorViewController!
    private var screenSize : CGRect!
    private var editorSize : CGSize!
    
    // MARK : - Outlets
    @IBOutlet var fakeContactPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var subject: UITextField!
    @IBOutlet var showCcBccButton: UIButton!
    
    // MARK: - Action Buttons
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet var encryptedButton: UIButton!
    @IBOutlet var expirationButton: UIButton!
    @IBOutlet var attachmentButton: UIButton!
    private var confirmExpirationButton: UIButton!
    
    // MARK: - Encryption password
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet var encryptedPasswordTextField: UITextField!
    @IBOutlet var encryptedActionButton: UIButton!
    

    // MARK: - Expiration Date
    @IBOutlet var expirationView: UIView!
    @IBOutlet var expirationDateTextField: UITextField!
    //@IBOutlet var expirationPicker: UIPickerView!

    
    // MARK: - Delegate and Datasource
    var datasource: ComposeViewNDataSource?
    var delegate: ComposeViewNDelegate?
    
    var selfView : UIView!
    
    // MARK: - Constants
    private let kDefaultRecipientHeight: CGFloat = 48.0
    private let kErrorMessageHeight: CGFloat = 48.0
    private let kNumberOfColumnsInTimePicker: Int = 2
    private let kNumberOfDaysInTimePicker: Int = 30
    private let kNumberOfHoursInTimePicker: Int = 24
    private let kCcBccContainerViewHeight: CGFloat = 96.0
    
    //
    private let kAnimationDuration = 0.25
    
    //
    private var errorView: UIView!
    private var errorTextView: UITextView!
    private var isShowingCcBccView: Bool = false
    private var hasExpirationSchedule: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selfView = self.view;
        self.screenSize = UIScreen.mainScreen().bounds
        
        //self.configureContactPickerTemplate()
        self.includeButtonBorder(encryptedButton)
        self.includeButtonBorder(expirationButton)
        self.includeButtonBorder(attachmentButton)
        self.includeButtonBorder(encryptedPasswordTextField)
        self.includeButtonBorder(expirationDateTextField)
        
        self.configureHtmlEditor()
        self.configureToContactPicker()
        self.configureCcContactPicker()
        self.configureBccContactPicker()
        self.configureSubject()
    
        self.configureEncryptionPasswordField()
        self.configureExpirationField()
        self.configureErrorMessage()
        
        self.view.bringSubviewToFront(showCcBccButton)
        self.view.bringSubviewToFront(subject);
        self.view.sendSubviewToBack(ccContactPicker)
        self.view.sendSubviewToBack(bccContactPicker)
        
//        self.expirationPicker.alpha = 0.0
//        self.expirationPicker.dataSource = self
//        self.expirationPicker.delegate = self
        
//        self.registerForKeyboardNotifications()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.notifyViewSize( false )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func contactPlusButtonTapped(sender: UIButton) {
        self.plusButtonHandle();
        
        self.notifyViewSize(true)
    }
    
    @IBAction func attachmentButtonTapped(sender: UIButton) {
        //self.endEditing(true)
        //self.delegate?.composeViewDidTapAttachmentButton(self)
    }
    
    @IBAction func expirationButtonTapped(sender: UIButton) {
        //self.endEditing(true)
        //self.expirationDateTextField.becomeFirstResponder()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.passwordView.alpha = 0.0
            self.buttonView.alpha = 0.0
            self.expirationView.alpha = 1.0
            
            self.toContactPicker.userInteractionEnabled = false
            self.ccContactPicker.userInteractionEnabled = false
            self.bccContactPicker.userInteractionEnabled = false
            self.subject.userInteractionEnabled = false
            
          //self.showExpirationPicker()
        })
    }

    @IBAction func encryptedButtonTapped(sender: UIButton) {
        self.delegate?.composeViewDidTapEncryptedButton(self)
        self.encryptedPasswordTextField.becomeFirstResponder()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.encryptedButton.setImage(UIImage(named: "encrypted_compose"), forState: UIControlState.Normal)
            self.passwordView.alpha = 1.0
            self.buttonView.alpha = 0.0
        })
    }
    @IBAction func didTapEncryptedDismissButton(sender: UIButton) {
        self.delegate?.composeViewDidTapEncryptedButton(self)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.encryptedPasswordTextField.text = ""
            self.passwordView.alpha = 0.0
            self.buttonView.alpha = 1.0
        })
    }
    
    
    // Mark: -- Private Methods
    private func includeButtonBorder(view: UIView) {
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.ProtonMail.Gray_C9CED4.CGColor
    }
    
    private func configureEncryptionPasswordField() {
        let passwordLeftPaddingView = UIView(frame: CGRectMake(0, 0, 12, self.encryptedPasswordTextField.frame.size.height))
        encryptedPasswordTextField.leftView = passwordLeftPaddingView
        encryptedPasswordTextField.leftViewMode = UITextFieldViewMode.Always
        
        let nextButton = UIButton()
        nextButton.addTarget(self, action: "didTapNextButton", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.setImage(UIImage(named: "next"), forState: UIControlState.Normal)
        nextButton.sizeToFit()
        
        let nextView = UIView(frame: CGRectMake(0, 0, nextButton.frame.size.width + 10, nextButton.frame.size.height))
        nextView.addSubview(nextButton)
        encryptedPasswordTextField.rightView = nextView
        encryptedPasswordTextField.rightViewMode = UITextFieldViewMode.Always
    }
    
    private func configureExpirationField() {
        let expirationLeftPaddingView = UIView(frame: CGRectMake(0, 0, 15, self.expirationDateTextField.frame.size.height))
        expirationDateTextField.leftView = expirationLeftPaddingView
        expirationDateTextField.leftViewMode = UITextFieldViewMode.Always
        
        self.confirmExpirationButton = UIButton()
        confirmExpirationButton.addTarget(self, action: "didTapConfirmExpirationButton", forControlEvents: UIControlEvents.TouchUpInside)
        confirmExpirationButton.setImage(UIImage(named: "confirm_compose"), forState: UIControlState.Normal)
        confirmExpirationButton.sizeToFit()
        
        let confirmView = UIView(frame: CGRectMake(0, 0, confirmExpirationButton.frame.size.width + 10, confirmExpirationButton.frame.size.height))
        confirmView.addSubview(confirmExpirationButton)
        expirationDateTextField.rightView = confirmView
        expirationDateTextField.rightViewMode = UITextFieldViewMode.Always
        //expirationDateTextField.delegate = self
    }
    
    private func configureErrorMessage() {
        self.errorView = UIView()
        self.errorView.backgroundColor = UIColor.whiteColor()
        self.errorView.clipsToBounds = true
        
        self.errorTextView = UITextView()
        self.errorTextView.backgroundColor = UIColor.clearColor()
        self.errorTextView.font = UIFont.robotoLight(size: UIFont.Size.h4)
        self.errorTextView.text = NSLocalizedString("Message password doesn't match.")
        self.errorTextView.textAlignment = NSTextAlignment.Center
        self.errorTextView.textColor = UIColor.whiteColor()
        self.errorTextView.sizeToFit()
        self.view.addSubview(errorView)
        errorView.addSubview(errorTextView)
        
//        errorView.mas_makeConstraints { (make) -> Void in
//            make.left.equalTo()(self.selfView)
//            make.right.equalTo()(self.selfView)
//            make.height.equalTo()(0)
//            make.top.equalTo()(self.passwordView.mas_bottom)
//        }
        
//        errorTextView.mas_makeConstraints { (make) -> Void in
//            make.left.equalTo()(self.selfView)
//            make.right.equalTo()(self.selfView)
//            make.height.equalTo()(self.errorTextView.frame.size.height)
//            make.top.equalTo()(self.errorView).with().offset()(8)
//        }
    }
    
    ///
    internal func notifyViewSize(animation : Bool)
    {
        UIView.animateWithDuration(animation ? self.kAnimationDuration : 0, delay:0, options: nil, animations: {
            //143
            self.updateViewSize()
            println("\(self.buttonView.frame)")
            println("\(self.expirationView.frame)")
            println("\(self.passwordView.frame)")
            let size = CGSize(width: self.view.frame.width, height: self.passwordView.frame.origin.y + self.passwordView.frame.height + self.editorSize.height)
            self.delegate?.ComposeViewNDidSizeChanged(size)
        }, completion: nil)
    }
    
    internal func configureSubject() {
        self.subject.addBorder(.Left, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
        self.subject.addBorder(.Right, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
        
        let subjectLeftPaddingView = UIView(frame: CGRectMake(0, 0, 12, self.subject.frame.size.height))
        self.subject.leftView = subjectLeftPaddingView
        self.subject.leftViewMode = UITextFieldViewMode.Always
    }
    
    internal func plusButtonHandle()
    {
        if (isShowingCcBccView) {
            UIView.animateWithDuration(self.kAnimationDuration, animations: { () -> Void in
                self.fakeContactPickerHeightConstraint.constant = self.toContactPicker.currentContentHeight
                self.ccContactPicker.alpha = 0.0
                self.bccContactPicker.alpha = 0.0
                self.showCcBccButton.setImage(UIImage(named: "plus_compose"), forState:UIControlState.Normal )
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(self.kAnimationDuration, animations: { () -> Void in
                self.ccContactPicker.alpha = 1.0
                self.bccContactPicker.alpha = 1.0
                self.fakeContactPickerHeightConstraint.constant = self.toContactPicker.currentContentHeight + self.ccContactPicker.currentContentHeight + self.bccContactPicker.currentContentHeight
                self.showCcBccButton.setImage(UIImage(named: "minus_compose"), forState:UIControlState.Normal )
                self.view.layoutIfNeeded()
            })
        }
        
        isShowingCcBccView = !isShowingCcBccView
    }
    
    internal func didTapConfirmExpirationButton() {
//        let selectedDay = expirationPicker.selectedRowInComponent(0)
//        let selectedHour = expirationPicker.selectedRowInComponent(1)
//        
//        if (selectedDay == 0 && selectedHour == 0) {
//            self.expirationDateTextField.shake(3, offset: 10.0)
//        } else {
//            if (!hasExpirationSchedule) {
//                self.expirationButton.setImage(UIImage(named: "expiration_compose_checked"), forState: UIControlState.Normal)
//                self.confirmExpirationButton.setImage(UIImage(named: "cancel_compose"), forState: UIControlState.Normal)
//            } else {
//                self.expirationDateTextField.text = ""
//                self.expirationPicker.selectRow(0, inComponent: 0, animated: true)
//                self.expirationPicker.selectRow(0, inComponent: 1, animated: true)
//                self.expirationButton.setImage(UIImage(named: "expiration_compose"), forState: UIControlState.Normal)
//                self.confirmExpirationButton.setImage(UIImage(named: "confirm_compose"), forState: UIControlState.Normal)
//            }
//            
//            hasExpirationSchedule = !hasExpirationSchedule
//            self.hideExpirationPicker()
//        }
    }
    
    internal func didTapNextButton() {
        self.delegate?.composeViewDidTapNextButton(self)
    }
    
    internal func showDefinePasswordView() {
        self.encryptedPasswordTextField.placeholder = NSLocalizedString("Define Password")
        self.encryptedPasswordTextField.secureTextEntry = true
        self.encryptedPasswordTextField.text = ""
    }
    
    internal func showConfirmPasswordView() {
        self.encryptedPasswordTextField.placeholder = NSLocalizedString("Confirm Password")
        self.encryptedPasswordTextField.secureTextEntry = true
        self.encryptedPasswordTextField.text = ""
    }
    
    internal func showPasswordHintView() {
        self.encryptedPasswordTextField.placeholder = NSLocalizedString("Define Hint")
        self.encryptedPasswordTextField.secureTextEntry = false
        self.encryptedPasswordTextField.text = ""
    }
    
    internal func showEncryptionDone() {
        didTapEncryptedDismissButton(encryptedButton)
        self.encryptedPasswordTextField.placeholder = NSLocalizedString("Define Password")
        self.encryptedPasswordTextField.secureTextEntry = true
        self.encryptedButton.setImage(UIImage(named: "encrypted_compose_checked"), forState: UIControlState.Normal)
    }
    
    internal func showExpirationPicker() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
           // self.expirationPicker.alpha = 1.0
        })
    }

    internal func hideExpirationPicker() {
        self.toContactPicker.userInteractionEnabled = true
        self.ccContactPicker.userInteractionEnabled = true
        self.bccContactPicker.userInteractionEnabled = true
        self.subject.userInteractionEnabled = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.expirationView.alpha = 0.0
            self.buttonView.alpha = 1.0
            //self.expirationPicker.alpha = 0.0
        })
    }
    
    internal func showPasswordAndConfirmDoesntMatch() {
        self.errorView.backgroundColor = UIColor.ProtonMail.Red_FF5959
        self.errorView.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.left.equalTo()(self)
            update.right.equalTo()(self)
            update.height.equalTo()(self.kErrorMessageHeight)
            update.top.equalTo()(self.encryptedPasswordTextField.mas_bottom)
        }
        
        self.errorTextView.shake(3, offset: 10)
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            //self.layoutIfNeeded()
        })
    }
    
    internal func hidePasswordAndConfirmDoesntMatch() {
        self.errorView.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.left.equalTo()(self.view)
            update.right.equalTo()(self.view)
            update.height.equalTo()(0)
            update.top.equalTo()(self.encryptedPasswordTextField.mas_bottom)
        }
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            //self.layoutIfNeeded()
        })
    }
    
    private func configureHtmlEditor(){
        
        self.editorSize = CGSize.zeroSize
        self.htmlEditor = HtmlEditorViewController()
        self.htmlEditor.delegate = self
        self.view.addSubview(htmlEditor.view);
        let size = CGSize(width: self.view.frame.width, height: self.passwordView.frame.origin.y + self.passwordView.frame.height)
        self.htmlEditor.view.frame = CGRect(x: 0, y: size.height, width: screenSize.width, height: 1000)
        self.htmlEditor.setFrame(CGRect(x: 0, y: 0, width: screenSize.width, height: 1000))

        htmlEditor.setHTML("<div><br></div><div><br></div><div>Sent from iPhone <a href=\"https://protonmail.ch\">ProtonMail</a>, encrypted email based in Switzerland.<br></div>")
    }
    
    private func updateViewSize()
    {
        let size = CGSize(width: self.view.frame.width, height: self.passwordView.frame.origin.y + self.passwordView.frame.height)
        self.htmlEditor.view.frame = CGRect(x: 0, y: size.height, width: editorSize.width, height: editorSize.height)
        self.htmlEditor.setFrame(CGRect(x: 0, y: 0, width: editorSize.width, height: editorSize.height))
    }
    
    private func configureToContactPicker() {
        toContactPicker = MBContactPicker()
        toContactPicker.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.view.addSubview(toContactPicker)
        toContactPicker.datasource = self
        toContactPicker.delegate = self
        
        toContactPicker.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.selfView).with().offset()(5)
            make.left.equalTo()(self.selfView)
            make.right.equalTo()(self.selfView)
            make.height.equalTo()(self.kDefaultRecipientHeight)
        }
    }
    
    private func configureCcContactPicker() {
        ccContactPicker = MBContactPicker()
        self.view.addSubview(ccContactPicker)
        
        ccContactPicker.datasource = self
        ccContactPicker.delegate = self
        ccContactPicker.alpha = 0.0
        
        ccContactPicker.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.toContactPicker.mas_bottom)
            make.left.equalTo()(self.selfView)
            make.right.equalTo()(self.selfView)
            make.height.equalTo()(self.toContactPicker)
        }
    }

    private func configureBccContactPicker() {
        bccContactPicker = MBContactPicker()
        self.view.addSubview(bccContactPicker)
        
        bccContactPicker.datasource = self
        bccContactPicker.delegate = self
        bccContactPicker.alpha = 0.0
        
        bccContactPicker.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.ccContactPicker.mas_bottom)
            make.left.equalTo()(self.selfView)
            make.right.equalTo()(self.selfView)
            make.height.equalTo()(self.ccContactPicker)
        }
    }

    private func updateContactPickerHeight(contactPicker: MBContactPicker, newHeight: CGFloat) {
        if (contactPicker == self.toContactPicker) {
            toContactPicker.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self.selfView)
                make.left.equalTo()(self.selfView)
                make.right.equalTo()(self.selfView)
                make.height.equalTo()(newHeight)
            })
        }
        else if (contactPicker == self.ccContactPicker) {
            ccContactPicker.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self.toContactPicker.mas_bottom)
                make.left.equalTo()(self.selfView)
                make.right.equalTo()(self.selfView)
                make.height.equalTo()(newHeight)
            })
        } else if (contactPicker == self.bccContactPicker) {
            bccContactPicker.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self.ccContactPicker.mas_bottom)
                make.left.equalTo()(self.selfView)
                make.right.equalTo()(self.selfView)
                make.height.equalTo()(newHeight)
            })
        }
        
        if (isShowingCcBccView) {
            fakeContactPickerHeightConstraint.constant = toContactPicker.currentContentHeight + ccContactPicker.currentContentHeight + bccContactPicker.currentContentHeight
        } else {
            fakeContactPickerHeightConstraint.constant = toContactPicker.currentContentHeight
        }

        
        UIView.animateWithDuration(NSTimeInterval(contactPicker.animationSpeed), animations: { () -> Void in
            self.view.layoutIfNeeded()
            contactPicker.contactCollectionView.addBorder(.Bottom, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
            contactPicker.contactCollectionView.addBorder(.Left, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
            contactPicker.contactCollectionView.addBorder(.Right, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
        })
    }
}


//html editor delegate
extension ComposeViewN : HtmlEditorViewControllerDelegate {
    func editorSizeChanged(size: CGSize) {
        self.editorSize = size
        self.notifyViewSize(false)
    }
}

// MARK: - MBContactPickerDataSource
extension ComposeViewN: MBContactPickerDataSource {
    func contactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        if (contactPickerView == toContactPicker) {
            contactPickerView.prompt = NSLocalizedString("To:")
        } else if (contactPickerView == ccContactPicker) {
            contactPickerView.prompt = NSLocalizedString("Cc:")
        } else if (contactPickerView == bccContactPicker) {
            contactPickerView.prompt = NSLocalizedString("Bcc:")
        }
        
        contactPickerView.contactCollectionView.addBorder(.Left, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
        contactPickerView.contactCollectionView.addBorder(.Right, color: UIColor.ProtonMail.Gray_C9CED4, borderWidth: 1.0)
        
        return self.datasource?.composeViewContactsModelForPicker(self, picker: contactPickerView)
    }
    
    func selectedContactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        return self.datasource?.composeViewSelectedContactsForPicker(self, picker: contactPickerView)
    }
}


// MARK: - MBContactPickerDelegate

extension ComposeViewN: MBContactPickerDelegate {
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didAddContact model: MBContactPickerModelProtocol!) {
        let contactPicker = contactPickerForContactCollectionView(contactCollectionView)
        
        //self.delegate?.composeView(self, didAddContact: model as! ContactVO, toPicker: contactPicker)
    }
    
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didRemoveContact model: MBContactPickerModelProtocol!) {
        let contactPicker = contactPickerForContactCollectionView(contactCollectionView)
        
        //self.delegate?.composeView(self, didRemoveContact: model as! ContactVO, fromPicker: contactPicker)
    }
    
    func contactPicker(contactPicker: MBContactPicker!, didEnterCustomText text: String!) {
        let customContact = ContactVO(id: "", name: text, email: text)
        
        contactPicker.addToSelectedContacts(customContact)
    }
    
    func contactPicker(contactPicker: MBContactPicker!, didUpdateContentHeightTo newHeight: CGFloat) {
        self.updateContactPickerHeight(contactPicker, newHeight: newHeight)
    }
    
    func didShowFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        self.view.bringSubviewToFront(contactPicker)
        if (contactPicker.frame.size.height <= contactPicker.currentContentHeight) {
            let pickerRectInWindow = self.view.convertRect(contactPicker.frame, toView: nil)
            let newHeight = self.view.window!.bounds.size.height - pickerRectInWindow.origin.y - contactPicker.keyboardHeight
            self.updateContactPickerHeight(contactPicker, newHeight: newHeight)
        }
        
        if !contactPicker.hidden {
            
        }
        
    }
    
    func didHideFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        self.view.sendSubviewToBack(contactPicker)
        if (contactPicker.frame.size.height > contactPicker.currentContentHeight) {
            self.updateContactPickerHeight(contactPicker, newHeight: contactPicker.currentContentHeight)
        }
    }
    
    // MARK: Private delegate helper methods
    
    private func contactPickerForContactCollectionView(contactCollectionView: MBContactCollectionView) -> MBContactPicker {
        var contactPicker: MBContactPicker = toContactPicker
        
        if (contactCollectionView == toContactPicker.contactCollectionView) {
            contactPicker = toContactPicker
        }
        else if (contactCollectionView == ccContactPicker.contactCollectionView) {
            contactPicker = ccContactPicker
        } else if (contactCollectionView == bccContactPicker.contactCollectionView) {
            contactPicker = bccContactPicker
        }
        
        return contactPicker
    }
    
    internal func customFilterPredicate(searchString: String!) -> NSPredicate! {
        return NSPredicate(format: "contactTitle CONTAINS[cd] %@ or contactSubtitle CONTAINS[cd] %@", argumentArray: [searchString, searchString])
    }
}

