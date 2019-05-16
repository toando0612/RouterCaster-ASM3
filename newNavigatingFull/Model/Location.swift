//
//  Location.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/4/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//



import Foundation
import MapKit
//import Contacts

class Location: NSObject, MKAnnotation {
    //variable for map MKAnnotation
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var avatar: String?
    var color: String?
    

    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D, avatar:String) {
        self.title = title
        self.avatar = avatar
        self.coordinate = coordinate
        self.color = ""
        super.init()
    }

    
    //choose color
    var markerTintColor: UIColor  {
        switch color {
        case "red":
            return .red
        case "cyan":
            return .cyan
        case "blue":
            return .blue
        case "purple":
            return .purple
        default:
            return .green
        }
    }
    
    //choose image
    var imageName: String? {
        switch  avatar {
        case "user1":
            return "user1"
        case "user2":
            return "user2"
        default:
            return "Statue"
        }
    }
    
    
    

    
    
    // Annotation right callout accessory opens this mapItem in Maps app
//    func mapItem() -> MKMapItem {
//        let addressDict = [CNPostalAddressStreetKey: subtitle!]
//        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = title
//        return mapItem
//    }
    
    
}

