import Foundation
import UIKit
import MessageKit

struct Member {
    let name: String
    let color: UIColor
    let id: String
    var profileImageUrl: String
    var avatar: UIImage?
}

struct Message {
    let member: Member
    let text: String
    let messageId: String
    let sentDate: Date
}
extension Message: MessageType {
    var sender: SenderType {
        return Sender(id: member.id, displayName: member.name)
    }
    
//    var sender: Sender {
//        return Sender(id: member.name, displayName: member.name)
//    }
    
//    var sentDate: Date {
//        return Date()
//    }
    
    var kind: MessageKind {
        return .text(text)
    }
}
extension Message: Comparable {
    //equal by id
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    //compare by date
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
