//
//  EditExtension.swift
//  newNavigatingFull
//
//  Created by Toan Do on 5/13/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    @objc func showInputDialog(title:String? = nil,
                               subtitle:String? = nil,
                               actionTitle:String? = "OK",
                               cancelTitle:String? = "Cancel",
                               inputPlaceholder:String? = nil,
                               inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                               cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                               actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .destructive, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func showConfirmDialog(title:String? = nil,
                                 actionTitle:String? = "OK",
                                 actionHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
        self.present(alert, animated: true, completion: nil)
    }
}

