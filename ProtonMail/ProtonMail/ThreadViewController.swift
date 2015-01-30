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

class ThreadViewController: ProtonMailViewController {
    
    var emailThread: EmailThread!
    
    @IBOutlet var threadView: ThreadView!
    
    override func loadView() {
        emailThread.isRead = true
        threadView = ThreadView(thread: emailThread)
        threadView.delegate = self
        
        self.view = threadView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRightButtons()
    }
    
    override func shouldShowSideMenu() -> Bool {
        return false
    }
    
    private func setupRightButtons() {
        var rightButtons: [UIBarButtonItem]
        
        let removeBarButtonItem = UIBarButtonItem(image: UIImage(named: "trash_selected"), style: UIBarButtonItemStyle.Plain, target: self, action: "removeButtonTapped")
        let spamBarButtonItem = UIBarButtonItem(image: UIImage(named: "spam_selected"), style: UIBarButtonItemStyle.Plain, target: self, action: "spamButtonTapped")
        let moreBarButtonItem = UIBarButtonItem(image: UIImage(named: "arrow_down"), style: UIBarButtonItemStyle.Plain, target: self, action: "moreButtonTapped")
        
        rightButtons = [moreBarButtonItem, spamBarButtonItem, removeBarButtonItem]
        self.navigationItem.setRightBarButtonItems(rightButtons, animated: true)
    }
    
    func removeButtonTapped() {
        
    }
    
    func spamButtonTapped() {
        
    }
    
    func moreButtonTapped() {
            
    }
}

extension ThreadViewController: ThreadViewDelegate {
    
    func threadViewDidTapForwardThread(threadView: ThreadView, thread: EmailThread) {
        
        println("threadViewDidTapForwardThread: \(thread.title)")
    }
    
    func threadViewDidTapReplyAllThread(threadView: ThreadView, thread: EmailThread) {

        println("threadViewDidTapReplyAllThread: \(thread.title)")
    }
    
    func threadViewDidTapReplyThread(threadView: ThreadView, thread: EmailThread) {
        
        println("threadViewDidTapReplyThread: \(thread.title)")
    }
}