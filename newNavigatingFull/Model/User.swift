//
//  User.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/29/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import Foundation
import UIKit

class User{
    var id: String
    var email: String
    var name: String
    var phone: String
    var friendList = Set<String>()
    var sentFriendRequest = Set<String>()
    var profileImageUrl: String
    var avatar: UIImage?

    init(id: String, email: String, name: String, phone: String, profileImageUrl: String ) {
        self.id = id
        self.email = email
        self.name = name
        self.phone = phone
        self.profileImageUrl = profileImageUrl
    }
}
