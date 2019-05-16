//
//  ChatController.swift
//  newNavigatingFull
//
//  Created by Donbosco on 5/9/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import Alamofire


class ChatController: MessagesViewController{
    var roomID = "defaultRoomID"
    var currentUserID = UserProperty.currentUser?.id
    var currentUserName = UserProperty.currentUser?.name
    var currentUserAvatar = UserProperty.currentUser?.avatar
    var     myself : Member! = nil
    var friendID = UserProperty.chatFriend?.id
    var friendName = UserProperty.chatFriend?.name
     var     myFriend : Member! = nil
    var messages: [Message] = []

   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("current user: ",currentUserID)
        print("current friend: ",friendID)
   
        print("current user avatar: ", currentUserAvatar)
        
        //temprary incase null
        myself = Member(name: currentUserName!, color: .blue, id: currentUserID!, profileImageUrl: UserProperty.currentUser!.profileImageUrl , avatar: UserProperty.currentUser?.avatar)
        myFriend = Member(name: friendName!, color: .red, id: friendID!,profileImageUrl: UserProperty.chatFriend!.profileImageUrl,avatar:UserProperty.chatFriend?.avatar )

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        

        //get chat room of the partner: myself and my friend
    Database.database().reference().child("friendships").child(currentUserID!).child(friendID!).observe(.value, with: {(snapshot) in
        print("friendships/user/friend/chatroom: ",snapshot);
        if let dictionary = snapshot.value as? [String: AnyObject] {
            print(dictionary["chatRoom"] as! String)
            self.roomID = dictionary["chatRoom"] as! String
            
            //go to chat room to get messages
            Database.database().reference(withPath: "chatrooms").child(dictionary["chatRoom"] as! String).observe( .childAdded, with: { (snapshot) in
                print("childAdded: observe", snapshot.value)

                 if let message = snapshot.value as? [String: Any]
                 {
                        guard message["sender"] != nil  else {return}
                        let senderID = message["sender"] as! String
                        print("sender: ",senderID)
                    //if sender is not myself: this message is from my friend
                        if senderID != self.currentUserID {
                            print("sender Name: ",message["senderName"] )
                            let myfriend = UserProperty.users[senderID]
                            let aFriend = Member(name: message["senderName"] as! String, color: .black, id: senderID, profileImageUrl: myfriend!.profileImageUrl, avatar: myfriend?.avatar)
//                            let aFriend = Member(name: message["senderName"] as! String, color: .red, id: senderID)
                            let content = message["content"]
                            print("my message online ",content )
                            let sentDate = message["sentDate"]
                            self.messages.append(Message(member: aFriend, text: content! as! String, messageId: message["messageId"] as! String, sentDate: Date(timeIntervalSinceReferenceDate: sentDate as! TimeInterval)))
                        }
                     //sender is myself for this message
                        else {
                             let me = UserProperty.currentUser
                            
                            self.myself = Member(name: message["senderName"] as! String, color: .blue, id: senderID, profileImageUrl: me!.profileImageUrl, avatar: me!.avatar)
                           
                            let sentDate = message["sentDate"]
                            self.messages.append(Message(member: self.myself, text: message["content"]! as! String, messageId: message["messageId"] as! String, sentDate: Date(timeIntervalSinceReferenceDate: sentDate as! TimeInterval)))
                        }
                }

                print("the message: ",self.messages)
                self.messages.sort()
                self.messagesCollectionView.reloadData()
                 self.messagesCollectionView.scrollToBottom(animated: true)
            },withCancel: nil)




            
        }
            
        }, withCancel: nil)
        print("got the chat room: ", self.roomID)
//        //go to chat room to get messages
//        Database.database().reference(withPath: "chatrooms").child(self.roomID).observe( .childAdded, with: { (snapshot) in
//            print("childAdded: observe", snapshot.value)
//
//            if let message = snapshot.value as? [String: Any]
//            {
//                guard message["sender"] != nil  else {return}
//                let senderID = message["sender"] as! String
//                print("sender: ",senderID)
//                if senderID != self.currentUserID {
//                    print("sender Name: ",message["senderName"] )
//                    let myfriend = UserProperty.users[senderID]
//                    let aFriend = Member(name: message["senderName"] as! String, color: .black, id: senderID, profileImageUrl: myfriend!.profileImageUrl, avatar: myfriend?.avatar)
//                    //                            let aFriend = Member(name: message["senderName"] as! String, color: .red, id: senderID)
//                    let content = message["content"]
//                    print("my message online ",content )
//                    let sentDate = message["sentDate"]
//                    self.messages.append(Message(member: aFriend, text: content! as! String, messageId: message["messageId"] as! String, sentDate: Date(timeIntervalSinceReferenceDate: sentDate as! TimeInterval)))
//                }
//                else {
//
//                    let sentDate = message["sentDate"]
//                    self.messages.append(Message(member: self.myself, text: message["content"]! as! String, messageId: message["messageId"] as! String, sentDate: Date(timeIntervalSinceReferenceDate: sentDate as! TimeInterval)))
//                }
//            }
//
//            print("the message: ",self.messages)
//            self.messages.sort()
//            self.messagesCollectionView.reloadData()
//            self.messagesCollectionView.scrollToBottom(animated: true)
//        },withCancel: nil)
//
        
        
        

    

//        print("message received: ",self.message)
    }
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    // MARK: - Helpers
//
//    private func insertNewMessage(_ message: Message) {
//        guard !messages.contains(message) else {
//            return
//        }
//
//        messages.append(message)
//        messages.sort()
//
//        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
////        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
//
//        messagesCollectionView.reloadData()
//
////        if shouldScrollToBottom {
////            DispatchQueue.main.async {
////                self.messagesCollectionView.scrollToBottom(animated: true)
////            }
////        }
//    }


}
extension ChatController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(id: myself.id, displayName: myself.name)
    }
    
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
//    func currentSender() -> Sender {
//        return Sender(id: member.name, displayName: member.name)
//    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 40
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension ChatController:  MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 4
    }
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {

        // 0 hide avatar
        return .init(width: 2, height: 2)
    }
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 2, height: 2)
    }
    
    

}
extension ChatController: MessagesDisplayDelegate {

    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.section]
        let color = message.member.color
        
        avatarView.image = message.member.avatar
//            UIImage(named: message.member.avatar)
        avatarView.backgroundColor = color
    }
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
//                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
//
//        // 1
//        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
//    }
//
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        return true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}
extension ChatController: MessageInputBarDelegate {
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
         print("input delegate: send: ",text)
        
        let newMessage = Message(
            member: myself,
            text: text,
            messageId: UUID().uuidString,
            sentDate: Date())
        //structure to post to firebase
        let postData : [String: Any]=[
            "content": text,
            "messageId": newMessage.messageId,
//            date is timestamp from 2001
            "sentDate": newMessage.sentDate.timeIntervalSinceReferenceDate ,
            "sender": myself.id,
            "senderName":myself.name]

        Database.database().reference(withPath: "chatrooms/\(roomID)").childByAutoId().setValue(postData)
// reset input bar
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}

//extension ChatController: MessageCellDelegate{
//
//}
//extension ChatController: MessagesCollectionView{
//    
//}
