//
//  RegisterController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/26/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var nickName: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    func setupAvatar(){
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatar()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func  imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel picker")
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backToLoginTap(_ sender: Any) {
        print("back");
        self.dismiss(animated: true)
    }
    
    @IBAction func registerTap(_ sender: Any) {
        if (nickName.text == ""){
            let alertController = UIAlertController(title: "Register Error", message: " Please enter your user name", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if (phoneNumber.text == ""){
            let alertController = UIAlertController(title: "Register Error", message: " Please enter your phone number", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if(password.text != confirmPassword.text){
            let alertController = UIAlertController(title: "Register Error", message: "Confirmation password does not match", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        else{
            guard let email = email.text, let password = password.text, let name = nickName.text, let phone = phoneNumber.text else{
                print("Form is not valid")
                return
            }
            // if valid => register new user
            Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
                if let error = error {
                    print("Register error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Register Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                
                guard let uid = user?.user.uid else{
                    return
                }
                
                Database.database().reference(withPath: "friendships/\(uid)").child("self").setValue("\(uid)")
                
                Database.database().reference(withPath: "friendRequests/\(uid)").child("self").setValue("\(uid)")
                
                //successfully authenticated user
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("avatars").child("\(imageName).jpg")
                
                
                if let profileImage = self.profileImageView.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
                    //            if let uploadData = self.profileImageView.image?.pngData() {
                    
                    storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                        
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
                            let values = ["name": name, "email": email, "phone": phone, "profileImageUrl": url.absoluteString]
                            let ref = Database.database().reference()
                            let userRef = ref.child("users").child(uid)
                            userRef.updateChildValues(values, withCompletionBlock: {(error, ref) in
                                if (error != nil){
                                    print(error!)
                                    return
                                }
                                
                                handleRegisterAndLogin(email: self.email.text!, password: self.password.text!)

                            })
                            
                        })
                        
                    })
                }
                //
            })
        }
        
        func handleRegisterAndLogin(email: String, password: String){
            Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
                if(error != nil){
                    print(error)
                    return
                }
                print(Auth.auth().currentUser?.uid)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            })
        }
    
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
