//
//  FriendTableCell.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/29/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//


import UIKit
import Firebase
import MapKit

class FriendTableCell: UITableViewCell, UISearchBarDelegate{
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var friendBtn: UIButton!
    
    @IBOutlet weak var friendSecondaryBtn: UIButton!
    
    @IBOutlet weak var friendBtnImage: UIImageView!
    
    var user: User?
    
    var mapView: MKMapView?
    
    var handleMoveToChatView: MoveToChatView? = nil
    
    @IBAction func primaryFriendTap(_ sender: Any) {
        print(user!.id)
        print(user!.name)
        print(user!.email)
        print(UserProperty.currentUser?.id)
        
        if((friendBtn.titleLabel?.text ==  "Add")){
            print("Implement send new request: ")
            print("I, \(UserProperty.currentUser!.name), sent friend request to: \(user!.name)")
            //save request to target
            Database.database().reference(withPath: "friendRequests/\(user!.id)").child("\(UserProperty.currentUser!.id)").setValue("\(UserProperty.currentUser!.name)")
            //            ViewController.friendVc.friendTableView.reloadData()
        }
        else if((friendBtn.titleLabel?.text ==  "Accept")){
            print("Implement accept request")
            print("I, \(UserProperty.currentUser!.id), accept to be friend with: \(user!.id)")
            //post "hi" to chat room
            let postData : [String: Any]=[
                "content": "hi",
                "messageId": "1",
                //            date is timestamp from 2001
                "sentDate": Date().timeIntervalSinceReferenceDate ,
                "sender": UserProperty.currentUser!.id,
                "senderName": UserProperty.currentUser!.name]
            
//        set up a new chat room
            let chatRef = Database.database().reference(withPath: "chatrooms").childByAutoId()
            let chatRoomKey = chatRef.key
           
            chatRef.child(chatRoomKey! ).setValue(postData)
            print("we will chat at chatroom: \(chatRoomKey)")
    

            Database.database().reference(withPath: "friendships/\(UserProperty.currentUser!.id)").child("\(user!.id)").child("chatRoom").setValue(chatRoomKey)
            print("saved my chatroom")
            
            //save chatroom id to friend location
            Database.database().reference(withPath: "friendships/\(user!.id)").child("\(UserProperty.currentUser!.id)").child("chatRoom").setValue(chatRoomKey)
            print("saved friend chatroom")
            
            //remove request
            Database.database().reference(withPath: "friendRequests/\(UserProperty.currentUser!.id)").child("\(user!.id)").removeValue()
            
            //            friendBtn.backgroundColor = .blue
            //            ViewController.friendVc.friendTableView.reloadData()
        }
            
            // if friends - implement chat here !!!!!!!!
        else if((friendBtn.titleLabel?.text ==  "Chat")){
            print("Implement chat function!")
            UserProperty.chatFriend = user
//            print(UserProperty.chatFriend?.id)
//            print(UserProperty.currentUser?.id)
            handleMoveToChatView?.moveToChatView()
            
        }
        
        // send request to friends
    }
    
    @IBAction func secondaryFriendTap(_ sender: Any) {
        if (friendSecondaryBtn.titleLabel?.text ==  "Delete"){
            print("delete friend request")
            Database.database().reference(withPath: "friendRequests/\(UserProperty.currentUser!.id)").child("\(user!.id)").removeValue()
        }
        else if (friendSecondaryBtn.titleLabel?.text ==  "Location"){
            print("Navigating to friend location")
 
            let coordinate = UserProperty.friendLocations[user!.id]?.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            let region = MKCoordinateRegion(center: coordinate!, span: span)
            self.mapView!.setRegion(region, animated: true)
            ViewController.friendVc.view.endEditing(true)
            ViewController.fpc.move(to: .half, animated: true)
        }
        
    
    }
}
