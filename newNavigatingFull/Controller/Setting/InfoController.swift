//
//  InfoController.swift
//  newNavigatingFull
//
//  Created by Toan Do on 5/13/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation

class InfoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var phoneText: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var editPhoneButton: UIButton!
    @IBOutlet weak var editPasswordButton: UIButton!
    @IBOutlet weak var profileAvatarView: UIImageView!
    
    @IBAction func backToSetting(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                let user = User(id: uid, email: (dictionary["email"] as? String)!, name: (dictionary["name"] as? String)!, phone: (dictionary["phone"] as? String)!, profileImageUrl: (dictionary["profileImageUrl"] as? String)!)
                self.setupIntoForm(user)
                
            }
        }, withCancel: nil)
        
    }
    
    func setupIntoForm(_ user: User){
        nameText.text = user.name
        emailText.text = user.email
        phoneText.text = user.phone
        profileAvatarView.loadImageUsingCacheWithUrlString(user.profileImageUrl)
    }
    func setupElements(){
        editNameButton.addTarget(self, action: #selector(handleEditName), for: .touchUpInside)
        editPhoneButton.addTarget(self, action: #selector(handleEditPhone), for: .touchUpInside)
        editPasswordButton.addTarget(self, action: #selector(handleEditPassword), for: .touchUpInside)
        profileAvatarView.translatesAutoresizingMaskIntoConstraints = false
        profileAvatarView.contentMode = .scaleAspectFill
        profileAvatarView.layer.cornerRadius = 20
        profileAvatarView.clipsToBounds = true
        profileAvatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEditAvatar)))
        profileAvatarView.isUserInteractionEnabled = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        super.viewDidAppear(animated)
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupElements()
        checkIfUserIsLoggedIn()
    }
    
    
    
    
    
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser?.uid == nil {
            //            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else {
            fetchUser()
        }
        
    }
    @objc func handleEditAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    @objc func handleEditPassword(){
        let alert = UIAlertController(title: "Edit Password", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Current Password"
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "New Password"
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (action:UIAlertAction) in
            guard let currentPassword =  alert.textFields?[0].text else {
                return
            }
            guard let newPassword =  alert.textFields?[1].text else {
                return
            }
            guard let user = Auth.auth().currentUser else {
                return
            }
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: currentPassword)
            user.reauthenticateAndRetrieveData(with: credential, completion: { (AuthDataResult, error) in
                if error != nil {
                    self.showConfirmDialog(title: "Incorrect Password", actionTitle: "OK")
                } else {
                    user.updatePassword(to: newPassword) { (error) in
                        if error != nil {
                            print("cannot updatePassword")
                        }else{
                            print("changed password successfully")
                        }
                    }
                }
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleEditName (){
        showInputDialog(title: "Edit Nickname",
                        subtitle: "Enter new Display Name .",
                        actionTitle: "OK",
                        cancelTitle: "Cancel",
                        inputKeyboardType: .default)
        { (input:String?) in
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            let ref = Database.database().reference()
            ref.child("users/\(uid)/name").setValue("\(input ?? "")") {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Name could not be saved: \(error).")
                } else {
                    self.nameText.text = ("\(input ?? "")")
                    self.showConfirmDialog(title: "Edited successfully", actionTitle: "OK")
                }
            }
        }
    }
    @objc func handleEditPhone(){
        showInputDialog(title: "Edit Phone",
                        subtitle: "Enter new PhoneNumber .",
                        actionTitle: "OK",
                        cancelTitle: "Cancel",
                        inputKeyboardType: .numberPad)
        { (input:String?) in
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            let ref = Database.database().reference()
            ref.child("users/\(uid)/phone").setValue("\(input ?? "")") {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Phone could not be saved: \(error).")
                } else {
                    self.phoneText.text = ("\(input ?? "")")
                    self.showConfirmDialog(title: "Edited successfully", actionTitle: "OK")
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileAvatarView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
        
        let alert = UIAlertController(title: "Save Avatar?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action:UIAlertAction) in
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    //                self.navigationItem.title = dictionary["name"] as? String
                    let user = User(id: uid, email: (dictionary["email"] as? String)!, name: (dictionary["name"] as? String)!, phone: (dictionary["phone"] as? String)!, profileImageUrl: (dictionary["profileImageUrl"] as? String)!)
                    self.changeAvatar(user)
                }
            }, withCancel: nil)
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    //                self.navigationItem.title = dictionary["name"] as? String
                    let user = User(id: uid, email: (dictionary["email"] as? String)!, name: (dictionary["name"] as? String)!, phone: (dictionary["phone"] as? String)!, profileImageUrl: (dictionary["profileImageUrl"] as? String)!)
                    self.profileAvatarView.loadImageUsingCacheWithUrlString(user.profileImageUrl)
                }
            }, withCancel: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeAvatar(_ user : User){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Storage.storage().reference(forURL: user.profileImageUrl).delete { error in
            if error != nil {
                print("Cannot delete from storage")
            } else {
                print("delete from storage successfully")
            }
        }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        if let profileImage = self.profileAvatarView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                if let error = error {
                    print(error)
                    return
                }
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let url = url else { return }
                    let ref = Database.database().reference()
                    ref.child("users/\(uid)/profileImageUrl").setValue("\(url)") {
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            print("ImageUrl could not be saved: \(error).")
                        } else {
                            self.showConfirmDialog(title: "Edited successfully", actionTitle: "OK")
                            print("ImageUrl is saved successfully")
                        }
                    }
                    
                })
                
            })
        }
    }
    func  imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel picker")
        dismiss(animated: true, completion: nil)
    }
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

