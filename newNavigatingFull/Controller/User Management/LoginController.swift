//
//  LoginController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/26/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var forgotPwdBtn: UIButton!
    
    @IBOutlet weak var facebookBtn: UIButton!
    
    @IBOutlet weak var appIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
        forgotPwdBtn.addTarget(self, action: #selector(forgorPasswordTap), for: .touchUpInside)
        facebookBtn.layer.cornerRadius = 10
        appIcon.layer.cornerRadius = 13
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

//    @objc func showInputDialog(title:String? = nil,
//                               subtitle:String? = nil,
//                               actionTitle:String? = "Send",
//                               cancelTitle:String? = "Cancel",
//                               inputPlaceholder:String? = nil,
//                               inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
//                               cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
//                               actionHandler: ((_ text: String?) -> Void)? = nil) {
//        
//        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
//        alert.addTextField { (textField:UITextField) in
//            textField.placeholder = inputPlaceholder
//            textField.keyboardType = inputKeyboardType
//        }
//        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
//            guard let textField =  alert.textFields?.first else {
//                actionHandler?(nil)
//                return
//            }
//            actionHandler?(textField.text)
//        }))
//        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    @objc func showConfirmDialog(title:String? = nil,
//                                 actionTitle:String? = "OK",
//                                 actionHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
//
//        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    

    
    @objc func forgorPasswordTap(){
        showInputDialog(title: "Send link to reset password",
                        subtitle: "Please enter valid email below.",
                        actionTitle: "Send",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Email",
                        inputKeyboardType: .emailAddress)
        { (input:String?) in
            Auth.auth().sendPasswordReset(withEmail: "\(input ?? "")") { error in
                self.showConfirmDialog(title: "Email sent. Click on the link sent to your email to reset your password", actionTitle: "OK")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginTap(_ sender: Any) {
        print("log in")
        handleLogin(email: email.text!, password: password.text!);
    }

    func handleLogin(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if(error != nil){
                let alertController = UIAlertController(title: "Login Error", message: "Wrong email or password. Please try again", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            print(Auth.auth().currentUser?.uid)
            //            self.dismiss(animated: true, completion: nil)
            ViewController.fpc.set(contentViewController: ViewController.searchVC)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            print("access token:")
            
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name,picture.type(large)"], tokenString: accessToken.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
            
            req.start(completionHandler:{ (connection, result, error) -> Void in
                if(error == nil)
                {
                    print("result \(result)")
                    let userInfo = result as? [String: AnyObject]
                    let userName = userInfo!["name"] as? String
                    let userEmail = userInfo!["email"] as? String
                    let picture = userInfo!["picture"]!["data"]!! as? AnyObject
                    let profileImageUrl = picture!["url"] as? String
                    
                    print(userInfo)
                    print(profileImageUrl!)
                    
                    Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if let error = error {
                            print("Login error: \(error.localizedDescription)")
                            let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(okayAction)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        let ref = Database.database().reference(fromURL: "https://project-2052d.firebaseio.com/")
                        
                        guard let uid = Auth.auth().currentUser?.uid else{
                            return
                        }
                        
                        Database.database().reference(withPath: "friendships/\(uid)").child("self").setValue("\(uid)")
                        
                        Database.database().reference(withPath: "friendRequests/\(uid)").child("self").setValue("\(uid)")
                        
                        let userRef = ref.child("users").child(uid)
                        // get user name, email
                        let values = ["name": userName, "email": userEmail, "profileImageUrl": profileImageUrl, "phone": ""]
                        userRef.updateChildValues(values, withCompletionBlock: {(error, ref) in
                            if (error != nil){
                                print(error)
                                return
                            }
                            print(Auth.auth().currentUser?.uid)
                            
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                            
                        })
                        
                        // Present the main view
                        //                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                        //                    UIApplication.shared.keyWindow?.rootViewController = viewController
                        //                    self.dismiss(animated: true, completion: nil)
                        //                }
                        
                    })
                    
                }
                else
                {
                    print("error \(error)")
                }
            })

        }
    }
    
    
    
    
    @IBAction func transitionToRegisterTap(_ sender: Any) {
        performSegue(withIdentifier: "registerSegue", sender: nil)
    }

}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
}

