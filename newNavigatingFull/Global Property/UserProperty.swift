//
//  UserProperty.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/3/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import Foundation
import MapKit
import UIKit

struct UserProperty {
    // User variable
    static var currentUser: User?
    static var users = [String: User]()
    static var userIdList = Set<String>()
    static var friendLocations = [String: Location]()
    static var friendOverlays = [String: MKOverlay]()
    static var friendDestinationAnnotation = [String: MKPointAnnotation]()
    
    static var chatFriend: User?
    
}
