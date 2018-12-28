//
//  MessageExtension.swift
//  ProtonMail
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


import Foundation
import CoreData
import Crypto

extension Message {
    
    struct Attributes {
        static let entityName = "Message"
        static let isDetailDownloaded = "isDetailDownloaded"
        static let messageID = "messageID"
        static let toList = "toList"
        static let sender = "sender"
        static let time = "time"
        static let title = "title"
        static let labels = "labels"
        
        static let messageType = "messageType"
        static let messageStatus = "messageStatus"
        
        // 1.9.1
        static let unRead = "unRead"
    }
    
    struct Constants {
        static let starredTag = "starred"
    }
    
    // MARK: - variables
    var allEmailAddresses: String {
        let lists: [String] = self.allEmails
        if lists.isEmpty {
            return ""
        }
        return lists.joined(separator: ",")
    }
    
    // MARK: - variables
    var allEmails: [String] {
        var lists: [String] = []
        
        if !toList.isEmpty {
            let to = Message.contactsToAddressesArray(toList)
            if !to.isEmpty  {
                lists.append(contentsOf: to)
            }
        }
        
        if !ccList.isEmpty {
            let cc = Message.contactsToAddressesArray(ccList)
            if !cc.isEmpty  {
                lists.append(contentsOf: cc)
            }
        }
        
        if !bccList.isEmpty {
            let bcc = Message.contactsToAddressesArray(bccList)
            if !bcc.isEmpty  {
                lists.append(contentsOf: bcc)
            }
        }
        
        return lists
    }
    
    func getScore() -> Message.SpamScore {
        if let e = Message.SpamScore(rawValue: self.spamScore.intValue) {
            return e
        }
        return .others
    }
    
    @discardableResult
    func add(labelID: String) -> String? {
        var outLabel: String?
        //1, 2, labels can't be in inbox,
        var addLabelID = labelID
        if labelID == Location.inbox.rawValue && (self.contains(label: "1") || self.contains(label: "8")) {
            // move message to 1 / 8
            addLabelID = "8"
        }
        
        if labelID == Location.inbox.rawValue && (self.contains(label: "2") || self.contains(label: "7")) {
            // move message to 2 / 7
            addLabelID = sentSelf ? Location.inbox.rawValue : "7"
        }
        
        if let context = self.managedObjectContext {
            let labelObjs = self.mutableSetValue(forKey: "labels")
            if let toLabel = Label.labelForLableID(addLabelID, inManagedObjectContext: context) {
                var exsited = false
                for l in labelObjs {
                    if let label = l as? Label {
                        if label == toLabel {
                            exsited = true
                            break
                        }
                    }
                }
                if !exsited {
                    outLabel = addLabelID
                    labelObjs.add(toLabel)
                }
            }
            self.setValue(labelObjs, forKey: "labels")
            
        }
        return outLabel;
    }
    
    /// in rush , clean up later
    func setAsDraft() {
        if let context = self.managedObjectContext {
            let labelObjs = self.mutableSetValue(forKey: "labels")
            if let toLabel = Label.labelForLableID(Location.draft.rawValue, inManagedObjectContext: context) {
                var exsited = false
                for l in labelObjs {
                    if let label = l as? Label {
                        if label == toLabel {
                            exsited = true
                            return
                        }
                    }
                }
                if !exsited {
                    labelObjs.add(toLabel)
                }
            }
            
            if let toLabel = Label.labelForLableID("1", inManagedObjectContext: context) {
                var exsited = false
                for l in labelObjs {
                    if let label = l as? Label {
                        if label == toLabel {
                            exsited = true
                            return
                        }
                    }
                }
                if !exsited {
                    labelObjs.add(toLabel)
                }
            }
            self.setValue(labelObjs, forKey: "labels")
        }
    }
    
    
    func firstValidFolder() -> String? {
        let labelObjs = self.mutableSetValue(forKey: "labels")
        for l in labelObjs {
            if let label = l as? Label {
                if label.exclusive == true {
                    return label.labelID
                }
                
                if !label.labelID.preg_match ("(?!^\\d+$)^.+$") {
                    if label.labelID != "1", label.labelID != "2", label.labelID != "5", label.labelID != "10" {
                        return label.labelID
                    }
                }
            }
        }
        
        return nil
    }
    
    @discardableResult
    func remove(labelID: String) -> String? {
        if Location.allmail.rawValue == labelID  {
            return Location.allmail.rawValue
        }
        var outLabel: String?
        if let _ = self.managedObjectContext {
            let labelObjs = self.mutableSetValue(forKey: "labels")
            for l in labelObjs {
                if let label = l as? Label {
                    // can't remove label 1, 2, 5
                    //case inbox   = "0"
                    //case draft   = "1"
                    //case sent    = "2"
                    //case starred = "10"
                    //case archive = "6"
                    //case spam    = "4"
                    //case trash   = "3"
                    //case allmail = "5"
                    if label.labelID == "1" || label.labelID == "2" || label.labelID == Location.allmail.rawValue {
                        continue
                    }
                    if label.labelID == labelID {
                        labelObjs.remove(label)
                        outLabel = labelID
                        break
                    }
                }
            }
            self.setValue(labelObjs, forKey: "labels")
        }
        return outLabel
    }
    
    
    func selfSent(labelID: String) -> String? {
        if let _ = self.managedObjectContext {
            let labelObjs = self.mutableSetValue(forKey: "labels")
            for l in labelObjs {
                if let label = l as? Label {
                    if labelID == Location.inbox.rawValue {
                        if label.labelID == "2" || label.labelID == "7" {
                            return Location.sent.rawValue
                        }
                    }
                    
                    if labelID == Location.sent.rawValue {
                        if label.labelID == Location.inbox.rawValue {
                            return Location.inbox.rawValue
                        }
                    
                    }
                }
            }
        }
        return nil
    }
    
    
    
    func getShowLocationNameFromLabels(ignored : String) -> String? {
        //TODO::fix me
        var lableOnly = false
        if ignored == Message.Location.sent.title {
            if contains(label: .trash) {
                return Message.Location.trash.title
            }
            
            if contains(label: .trash) {
                return Message.Location.spam.title
            }
            
            if contains(label: .trash) {
                return Message.Location.archive.title
            }
            lableOnly = true
        }
        
        let labels = self.labels
        for l in labels {
            if let label = l as? Label {
                if label.exclusive == true && label.name != ignored {
                    return label.name
                } else if !lableOnly {
                    if let new_loc = Message.Location(rawValue: label.labelID), new_loc != .starred && new_loc != .allmail && new_loc.title != ignored {
                        return new_loc.title
                    }
                    
                }
            }
        }
        return nil
    }

    var subject : String {
        return title
    }
    
    var displaySender : String {
        get {
            let sc = senderContactVO
            return sc!.name.isEmpty ?  sc!.email : sc!.name
        }
        
    }
    
    // MARK: - methods
    convenience init(context: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entity(forEntityName: Attributes.entityName, in: context)!, insertInto: context)
    }
    
    /// Removes all messages from the store.
    class func deleteAll(inContext context: NSManagedObjectContext) {
        context.deleteAll(Attributes.entityName)
    }
    
    /**
     delete the message from local cache only use the message id
     
     :param: messageID String
     */
    class func deleteMessage(_ messageID : String) {
        let context = sharedCoreDataService.mainManagedObjectContext
        context.performAndWait {
            if let message = Message.messageForMessageID(messageID, inManagedObjectContext: context) {
                let labelObjs = message.mutableSetValue(forKey: "labels")
                labelObjs.removeAllObjects()
                message.setValue(labelObjs, forKey: "labels")
                context.delete(message)
            }
            if let error = context.saveUpstreamIfNeeded() {
                PMLog.D("error: \(error)")
            }
        }
    }

    class func messageForMessageID(_ messageID: String, inManagedObjectContext context: NSManagedObjectContext) -> Message? {
        return context.managedObjectWithEntityName(Attributes.entityName, forKey: Attributes.messageID, matchingValue: messageID) as? Message
    }
    
    class func messagesForObjectIDs(_ objectIDs: [NSManagedObjectID], inManagedObjectContext context: NSManagedObjectContext, error: NSErrorPointer) -> [Message]? {
        return context.managedObjectsWithEntityName(Attributes.entityName, forManagedObjectIDs: objectIDs, error: error) as? [Message]
    }
    
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        replaceNilStringAttributesWithEmptyString()
    }
    
    // MARK: methods
    func decryptBody(keys: Data, passphrase: String) throws -> String? {
        return try body.decryptMessage(binKeys: keys, passphrase: passphrase)
    }
    
    //const (
    //  ok         = 0
    //  notSigned  = 1
    //  noVerifier = 2
    //  failed     = 3
    //  )
    func verifyBody(verifier : Data, passphrase: String) -> SignStatus {
        guard let passphrase = sharedUserDataService.mailboxPassword,
            case let keys = sharedUserDataService.addressPrivKeys else
        {
                return .failed
        }
        
        do {
            let time : Int64 = Int64(round(self.time?.timeIntervalSince1970 ?? 0))
            if let verify = try body.verifyMessage(verifier: verifier, binKeys: keys, passphrase: passphrase, time: time) {
                let status = verify.verify()
                return SignStatus(rawValue: status) ?? .notSigned
            }
        } catch {
        }
        return .failed
    }
    
    func split() throws -> ModelsEncryptedSplit? {
        return try body.split()
    }
    
    func getSessionKey(keys: Data, passphrase: String) throws -> ModelsSessionSplit? {
        return try split()?.keyPacket().getSessionFromPubKeyPackage(passphrase, privKeys: keys)
    }
    
    func bodyToHtml() -> String {
        if lockType == .plainTextLock {
            return "<div>" + body.ln2br() + "</div>"
        } else {
            let body_without_ln = body.rmln()
            return "<div><pre>" + body_without_ln.lr2lrln() + "</pre></div>"
        }
    }
    
    func decryptBodyIfNeeded() throws -> String? {
        PMLog.D("Flags: \(self.flag.description)")
        
        let flag = self.flag
        if !checkIsEncrypted() {
            if isPlainText() {
                return body.ln2br() 
            }
            return body
        } else {
            
            if let passphrase = sharedUserDataService.mailboxPassword ?? self.cachedPassphrase,
                var body = try decryptBody(keys: sharedUserDataService.addressPrivKeys, passphrase: passphrase) {
                //PMLog.D(body)
                if isEncrypted == 8 || isEncrypted == 9 {
                    if let mimeMsg = MIMEMessage(string: body) {
                        if let html = mimeMsg.mainPart.part(ofType: "text/html")?.bodyString {
                            body = html
                        } else if let text = mimeMsg.mainPart.part(ofType: "text/plain")?.plainString {
                            body = text.encodeHtml()
                            body = "<html><body>\(body.ln2br())</body></html>"
                        }
                        
                        if let cidPart = mimeMsg.mainPart.partCID(),
                            var cid = cidPart.cid,
                            let rawBody = cidPart.rawBodyString {
                            cid = cid.preg_replace("<", replaceto: "")
                            cid = cid.preg_replace(">", replaceto: "")
                            let attType = "image/jpg" //cidPart.headers[.contentType]?.body ?? "image/jpg;name=\"unknow.jpg\""
                            let encode = cidPart.headers[.contentTransferEncoding]?.body ?? "base64"
                            body = body.stringBySetupInlineImage("src=\"cid:\(cid)\"", to: "src=\"data:\(attType);\(encode),\(rawBody)\"")
                        }
                    } else { //backup plan
                        body = body.multipartGetHtmlContent ()
                    }
                } else if isEncrypted == 7 {
                    if isPlainText() {
                        body = body.encodeHtml()
                        body = body.ln2br()
                        return body
                    } else {
                        return body
                    }
                }
                if isPlainText() {
                    body = body.encodeHtml()
                    return body.ln2br() 
                }
                return body
            }
            return nil
        }
    }
    
    func encryptBody(_ body: String, mailbox_pwd: String, error: NSErrorPointer?) {
        let address_id = self.getAddressID;
        if address_id.isEmpty {
            return
        }
        
        do {
            let key = sharedUserDataService.getAddressPrivKey(address_id: address_id)
            self.body = try body.encrypt(withAddr: address_id, mailbox_pwd: mailbox_pwd, key: key) ?? ""
        } catch let error {//TODO:: error handling
            PMLog.D(any: error.localizedDescription)
            self.body = ""
        }
        
    }
    
    func checkIsEncrypted() -> Bool! {
        PMLog.D(any: isEncrypted.intValue)
        let enc_type = EncryptTypes(rawValue: isEncrypted.intValue) ?? EncryptTypes.inner
        let checkIsEncrypted:Bool = enc_type.isEncrypted
        return checkIsEncrypted
    }
    
    func isPlainText() -> Bool {
        if let type = mimeType, type.lowercased() == "text/plain" {
            return true
        }
        return false
    }
    
    var encryptType : EncryptTypes! {
        let enc_type = EncryptTypes(rawValue: isEncrypted.intValue) ?? EncryptTypes.inner
        return enc_type
    }
    
    var lockType : LockTypes! {
        return self.encryptType.lockType
    }
    
    //this function need to factor
    var getAddressID: String {
        get {
            if let addr = defaultAddress {
                return addr.address_id
            }
            return ""
        }
    }
    
    //this function need to factor
    var defaultAddress : Address? {
        get {
            if let addressID = addressID, !addressID.isEmpty {
                if let add = sharedUserDataService.userAddresses.indexOfAddress(addressID), add.send == 1 {
                    return add;
                } else {
                    if let add = sharedUserDataService.userAddresses.defaultSendAddress() {
                        return add;
                    }
                }
            } else {
                if let addr = sharedUserDataService.userAddresses.defaultSendAddress() {
                    return addr
                }
            }
            return nil
        }
    }
    
    //this function need to factor
    var fromAddress : Address? {
        get {
            if let addressID = addressID, !addressID.isEmpty {
                if let add = sharedUserDataService.userAddresses.indexOfAddress(addressID) {
                    return add;
                }
            }
            return nil
        }
    }
    
    var senderContactVO : ContactVO! {
        var sender: Sender?
        if let senderRaw = self.sender?.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(Sender.self, from: senderRaw)
        {
            sender = decoded
        }
        
        return ContactVO(id: "",
                         name: sender?.name ?? "",
                         email: sender?.address ?? "")
    }
    
    func copyMessage (_ copyAtts : Bool) -> Message {
        let message = self
        let newMessage = Message(context: sharedCoreDataService.mainManagedObjectContext)
        newMessage.toList = message.toList
        newMessage.bccList = message.bccList
        newMessage.ccList = message.ccList
        newMessage.title = message.title
        newMessage.time = Date()
        newMessage.body = message.body
        newMessage.isEncrypted = message.isEncrypted
        newMessage.sender = message.sender
        newMessage.replyTos = message.replyTos
        
        newMessage.orginalTime = message.time
        newMessage.orginalMessageID = message.messageID
        newMessage.expirationOffset = 0
        
        newMessage.addressID = message.addressID
        newMessage.messageStatus = message.messageStatus
        newMessage.numAttachments = message.numAttachments
        newMessage.mimeType = message.mimeType
        newMessage.setAsDraft()

        if let error = newMessage.managedObjectContext?.saveUpstreamIfNeeded() {
            PMLog.D("error: \(error)")
        }
        
        var key: Key?
        if let address_id = message.addressID,
            let userinfo = sharedUserDataService.userInfo,
            let addr = userinfo.userAddresses.indexOfAddress(address_id) {
            key = addr.keys.first
        }
        
        for (index, attachment) in message.attachments.enumerated() {
            PMLog.D("index: \(index)")
            if let att = attachment as? Attachment {
                if att.inline() || copyAtts {
                    let attachment = Attachment(context: newMessage.managedObjectContext!)
                    attachment.attachmentID = att.attachmentID
                    attachment.message = newMessage
                    attachment.fileName = att.fileName
                    attachment.mimeType = "image/jpg"
                    attachment.fileData = att.fileData
                    attachment.fileSize = att.fileSize
                    attachment.headerInfo = att.headerInfo
                    attachment.localURL = att.localURL
                    attachment.keyPacket = att.keyPacket
                    attachment.isTemp = true
                    do {
                        if let k = key,
                            let sessionPack = try att.getSession(keys: sharedUserDataService.addressPrivKeys),
                            let session = sessionPack.session(),
                            let algo = sessionPack.algo(),
                            let newkp = try session.getKeyPackage(strKey: k.publicKey, algo: algo) {
                                let encodedkp = newkp.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                                attachment.keyPacket = encodedkp
                                attachment.keyChanged = true
                        }
                    } catch {
                        
                    }
                    
                    if let error = attachment.managedObjectContext?.saveUpstreamIfNeeded() {
                        PMLog.D("error: \(error)")
                    }
                }
                
            }
        }
        return newMessage
    }
    
    func fetchDetailIfNeeded(_ completion: @escaping MessageDataService.CompletionFetchDetail) {
        sharedMessageDataService.fetchMessageDetailForMessage(self, completion: completion)
    }
}



