//
//  MapProperty.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/3/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import Foundation
import MapKit
import UIKit

struct MapProperty {
    static var overlayColor: UIColor?
    static var selectedPin:MKPlacemark? = nil
    static var chosenRoute: MKRoute?
    static var directionSteps: [String] = []
    static var transportType: MKDirectionsTransportType = .automobile
    static var showFriendLocations: Bool = true
    static var distanceUnit: String = "km"
}
