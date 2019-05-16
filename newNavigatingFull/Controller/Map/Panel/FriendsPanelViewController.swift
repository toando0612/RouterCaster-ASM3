//
//  FriendsPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/23/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Alamofire
import MapKit

class FriendsPanelViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var showFriendListBtn: UIButton!
    
    @IBOutlet weak var showFriendRequestBtn: UIButton!
    
    @IBOutlet weak var friendListAndRequestBtnView: UIView!
    
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    @IBOutlet weak var friendSearchBar: UISearchBar!
    
    @IBOutlet weak var friendTableView: UITableView!
    
    var handleMoveToChatView: MoveToChatView? = nil
    
    var mapView: MKMapView?
    
    var users: [String: AnyObject] = [String: AnyObject]()

    var didLoad = true
    
    var searchingIdList = Set<String>()
    var searchingAllUser = false
    var showingFriendRequest = false
    
    var handleMoveSideMenu: MoveSideMenu? = nil
    
    @objc func swipeLeftToRight(){
        print("swipe")
        handleMoveSideMenu?.showSideMenu()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftLeftToRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftToRight))
        swiftLeftToRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swiftLeftToRight)
        
        observe()
        friendSearchBar.delegate = self
        friendTableView.delegate = self
        friendTableView.dataSource = self
        showFriendListBtn.layer.cornerRadius = 13
        showFriendListBtn.backgroundColor = UIColor(hue: 0.3611, saturation: 1, brightness: 0.77, alpha: 1.0)
        showFriendRequestBtn.layer.cornerRadius = 13
        friendListAndRequestBtnView.layer.cornerRadius = 13
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        ViewController.fpc.track(scrollView: friendTableView)
        observe()
        self.friendTableView.reloadData()
    }
    
    func observe(){
        Database.database().reference().child("friendships").child(UserProperty.currentUser!.id).observe(.value, with: {(snapshot) in
            print(snapshot);
            if let dictionary = snapshot.value as? [String: AnyObject]{
               
                UserProperty.currentUser!.friendList = []
                dictionary.forEach({(key,value) in
                     print("friendships dic: ",key," - ",value)
                    if(key != "self" && key != UserProperty.currentUser!.id){
                        print("a friend: ",key)
                        UserProperty.currentUser!.friendList.insert(key)
                    }
                })
                
            }
            if (self.showingFriendRequest == false){
                self.searchingIdList = UserProperty.currentUser!.friendList
            }
            
            self.friendTableView.reloadData()
            print("friend list: \(UserProperty.currentUser!.friendList)")
        }, withCancel: nil)
        
        Database.database().reference().child("friendRequests").child(UserProperty.currentUser!.id).observe(.value, with: {(snapshot) in
            print(snapshot);
            if let dictionary = snapshot.value as? [String: String]{
                print("friendrequest :")
                UserProperty.currentUser!.sentFriendRequest = []
                dictionary.forEach({(key,value) in
                    if(key != "self"){
                       UserProperty.currentUser!.sentFriendRequest.insert(key)
                    }
                })
            }
            if(self.showingFriendRequest == true){
                self.searchingIdList = UserProperty.currentUser!.sentFriendRequest
            }
            
            self.friendTableView.reloadData()
            print("friend request:  \(UserProperty.currentUser!.sentFriendRequest)")
        }, withCancel: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 10, *) {
            visualEffect.layer.cornerRadius = 9.0
            visualEffect.clipsToBounds = true
        }
    }
    
    func refrestUsersAvatar() {
        for i in 0...friendTableView.numberOfSections-1
        {
            // fix later !!!!!!!!!!!!!!!!
            if (i == 0 ){
                return
            }
            for j in 0...friendTableView.numberOfRows(inSection: i)-1
            {
                if let cell = friendTableView.cellForRow(at: NSIndexPath(row: j, section: i) as IndexPath) as? FriendTableCell {
                    cell.avatar.image = nil
                }
                
            }
        }
    }
    
    @IBAction func friendListTap(_ sender: Any) {
        if(showingFriendRequest == true){
            refrestUsersAvatar()
            showFriendListBtn.backgroundColor = UIColor(hue: 0.3611, saturation: 1, brightness: 0.77, alpha: 1.0)
            showFriendRequestBtn.backgroundColor = .white
            self.view.endEditing(true)
            showingFriendRequest = false
            searchingIdList = UserProperty.currentUser!.friendList
            friendTableView.reloadData()
        }
        
    }
    
    @IBAction func friendRequestTap(_ sender: Any) {
        if(showingFriendRequest == false){
            refrestUsersAvatar()
            showFriendRequestBtn.backgroundColor = UIColor(hue: 0.3611, saturation: 1, brightness: 0.77, alpha: 1.0)
            showFriendListBtn.backgroundColor = .white
            self.view.endEditing(true)
            showingFriendRequest = true
            searchingIdList = UserProperty.currentUser!.sentFriendRequest
            friendTableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var newUserIdList = Set<String>()
        if(showingFriendRequest == true){
            if (searchText == ""){
                searchingIdList = UserProperty.currentUser!.sentFriendRequest
                friendTableView.reloadData()
                return
            }
            for id in UserProperty.currentUser!.sentFriendRequest{
                let userName = (UserProperty.users[id]!).name
                if ((userName.lowercased().contains(searchText.lowercased()))){
                    newUserIdList.insert(id)
                }
            }
            searchingIdList = newUserIdList
            friendTableView.reloadData()
        }
        else if (showingFriendRequest == false){
            if (searchText == ""){
                for id in UserProperty.userIdList{
                    let userName = (UserProperty.users[id]!).name
                    if (!UserProperty.currentUser!.sentFriendRequest.contains(id)){
                        newUserIdList.insert(id)
                    }
                }
                return
            }
            for id in UserProperty.userIdList{
                let userName = (UserProperty.users[id]!).name
                if ((userName.lowercased().contains(searchText.lowercased())) && !UserProperty.currentUser!.sentFriendRequest.contains(id)){
                    newUserIdList.insert(id)
                }
            }
            searchingIdList = newUserIdList
            friendTableView.reloadData()
        }
        
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if(showingFriendRequest == false){
            searchingAllUser = false
            searchingIdList = UserProperty.currentUser!.friendList
            friendTableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if (showingFriendRequest == false){
            searchingAllUser = true
//            searchingIdList = ViewController.userIdList
            var newSearchList = Set<String>()
            for userId in UserProperty.userIdList {
                if(userId == UserProperty.currentUser?.id) { continue}
                if(!UserProperty.currentUser!.sentFriendRequest.contains(userId)){
                    newSearchList.insert(userId)
                }
            }
            searchingIdList = newSearchList
            friendTableView.reloadData()
        }
        ViewController.fpc.move(to: .full, animated: true)
        friendSearchBar.showsCancelButton = true
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchingAllUser = false
        friendSearchBar.resignFirstResponder()
        friendSearchBar.placeholder = "Search for a friend"
        friendSearchBar.showsCancelButton = false
        ViewController.fpc.move(to: .half, animated: true)
        friendTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return searchingIdList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendTableCell
        var userId =  Array(searchingIdList)[indexPath.row]
        
        cell.friendBtn.layer.cornerRadius = 13
        cell.friendSecondaryBtn.layer.cornerRadius = 13
        
        cell.handleMoveToChatView = handleMoveToChatView
        if (UserProperty.currentUser!.friendList.contains(userId)){
            cell.friendBtn.backgroundColor = UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0)
            cell.friendBtn.setTitle("Chat", for: .normal)
            cell.friendSecondaryBtn.setTitle("Location", for: .normal)
            cell.friendSecondaryBtn.backgroundColor = .lightGray
            cell.friendSecondaryBtn.isHidden = false
        }
        else if (UserProperty.currentUser!.sentFriendRequest.contains(userId)){
            cell.friendBtn.backgroundColor = .orange
            cell.friendBtn.setTitle("Accept", for: .normal)
            cell.friendSecondaryBtn.backgroundColor = .lightGray
            cell.friendSecondaryBtn.setTitle("Delete", for: .normal)
            cell.friendSecondaryBtn.isHidden = false
        }
        else{
            cell.friendBtn.backgroundColor = .white
            cell.friendBtn.setTitle("Add", for: .normal)
            cell.friendSecondaryBtn.isHidden = true
        }

        if (UserProperty.users[userId] != nil){
            let userName = (UserProperty.users[userId])!.name
            cell.name?.text = userName
            cell.avatar.layer.cornerRadius = cell.avatar.frame.width/2
            cell.mapView = mapView!
            
            cell.user = UserProperty.users[userId]
            cell.avatar.image = UserProperty.users[userId]!.avatar
        }
       
        
        return cell
    }


}
