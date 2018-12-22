//
//  Message.swift
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

final public class Message: NSManagedObject {
    ///Mark -- new orders
    ///
    @NSManaged public var action: NSNumber?
    
    ///"AddressID":"222",
    @NSManaged public var addressID : String?
    ///"BCCList":[ { "Address":"", "Name":"", "Group": ""} ]
    @NSManaged public var bccList: String
    ///"Body":"-----BEGIN PGP MESSAGE-----.*-----END PGP MESSAGE-----",
    @NSManaged public var body: String
    
    
    ///local use and transient
    @NSManaged public var cachedPassphraseRaw: NSData? // transient
    ///local use and transient
    @NSManaged public var cachedPrivateKeysRaw: NSData? // transient
    ///local use and transient
    ///TODO: can this be kind of transient relatioship?
    @NSManaged public var cachedAuthCredentialRaw: NSData? // transient
    ///local use and transient
    ///TODO: addresses can also be in db, currently they are received from UserInfo singleton via message.defaultAddress getter
    @NSManaged public var cachedAddressRaw: NSData? // transient
    
    
    ///"CCList":[ { "Address":"", "Name":"", "Group": ""} ]
    @NSManaged public var ccList: String
    ///local use for sending set expiration offset
    @NSManaged public var expirationOffset : Int32
    ///"ExpirationTime":0,
    @NSManaged public var expirationTime: Date?
    /// Flags : bitsets for maybe different flag. defined in [Message.Flag]
    @NSManaged public var flags: NSNumber
    ///"Header":"(No Header)",
    @NSManaged public var header: String?
    
    ///local use, check if details downloaded
    @NSManaged public var isDetailDownloaded: Bool
    @available(*, deprecated, message: "use flag instead")
    @NSManaged public var isEncrypted: NSNumber
    
    ////local use, to check draft latest update time to decide pick cache or remote. should use the server time.
    @NSManaged public var lastModified: Date?
    /// ID : message id -- "ASnfew8asds92SDnsakr=="
    @NSManaged public var messageID: String
    /// local use, to check if message has metadata or not. some logic will fetch the metadata based on this
    @NSManaged public var messageStatus : NSNumber  // bit 0x00000000 no metadata  0x00000001 has
    /// local use, 0 is normal messages. 1 is review/rating tempery message
    @NSManaged public var messageType : NSNumber  // 0 message 1 rate
    ///"MIMEType": "text/html",
    @NSManaged public var mimeType : String?
    @available(*, deprecated, message: "this used to check if observed event needs to trigger a api call. we don't want to do it anymore")
    @NSManaged public var needsUpdate : Bool
    ///"NumAttachments":0,
    @NSManaged public var numAttachments: NSNumber
    ///local use, only when send/draft/reply/forward. to track the orginal message id
    @NSManaged public var orginalMessageID: String?
    ///local use, for sending. orginal message time. sometimes need it in the body
    @NSManaged public var orginalTime: Date?
    ///local use, the encrypted body encrypt by password
    @NSManaged public var passwordEncryptedBody: String
    ///local use, the pwd
    @NSManaged public var password: String
    ///local use, pwd hint
    @NSManaged public var passwordHint: String
    
    ///"ReplyTos": [{"Address":"", "Name":""}]
    @NSManaged public var replyTos: String?
    ///"Sender": { "Address":"", "Name":"" }
    @NSManaged public var sender: String?
    ///"Size":6959782,
    @NSManaged public var size: NSNumber
    ///"SpamScore": 101,  // 100 is PM spoofed, 101 is dmarc failed
    @NSManaged public var spamScore: NSNumber
    ///"Time":1433649408,
    @NSManaged public var time: Date?
    /// Subject : message subject -- "Fw: test"
    @NSManaged public var title: String
    ///"ToList":[ { "Address":"", "Name":"", "Group": ""} ]
    @NSManaged public var toList: String
    /// Unread : is message read / unread -- 0
    @NSManaged public var unRead: Bool
    
    
    /// Mark -- relationship
    
    //"Attachments":[ { }, {} ]
    @NSManaged public var attachments: NSSet
    //"LabelIDs":[ "1", "d3HYa3E394T_ACXDmTaBub14w==" ],
    @NSManaged public var labels: NSSet
    
    

    ///***Those values api returns them but client skip it
    ///"Order": 367
    ///ConversationID = "wgPpo3deVBrGwP3X8qZ-KSb0TtQ7_qy8TcISzCt2UQ==";
    ///ExternalID = "a34aa56f-150f-cffc-587b-83d7ca798277@emailprivacytester.com";
    ///Mark -- Remote values
    
    
    //@NSManaged public var tag: String
    
    //temp cache memory only
    var checkingSign : Bool = false
    var checkedSign : Bool = false
    var pgpType : PGPType = .none
    var unencrypt_outside : Bool = false
    typealias ObjectIDContainer = ObjectBox<Message>
}

//IsEncrypted = 2;
//IsForwarded = 0;
//IsReplied = 0;
//IsRepliedAll = 0;

