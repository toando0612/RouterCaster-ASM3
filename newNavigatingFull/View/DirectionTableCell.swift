//
//  Cell.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/10/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class DirectionTableCell: UITableViewCell {
    
    @IBOutlet weak var directionButton: UIButton!
    
    @IBOutlet weak var directionExtraInfo: UILabel!
    
    @IBOutlet weak var directionDistance: UILabel!
    
    @IBOutlet weak var directionTime: UILabel!
    
    var route: MKRoute?
    
    var overlay: MKOverlay?
    
    @IBAction func goTap(_ sender: Any) {
        MapProperty.chosenRoute = route
        ViewController.fpc.set(contentViewController: ViewController.inDirectionVc)
        ViewController.searchVC.matchingItems = []
        
        Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)/destination").updateChildValues(["lat": MapProperty.selectedPin!.coordinate.latitude, "lon": MapProperty.selectedPin!.coordinate.longitude, "routeName": MapProperty.chosenRoute!.name, "transportType": MapProperty.transportType.rawValue ])
        
    }
    
//        ViewController.inDirectionVc.route = self.route
//        ViewController.inDirectionVc.directionName.text = route!.name
//        ViewController.inDirectionVc.directionTime.text = String(route!.expectedTravelTime)
//        ViewController.inDirectionVc.chosenOverlay = overlay

    /*
     @IBOutlet weak var testView: UIView!
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
