//
//  InDirectionPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/11/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class InDirectionPanelViewController: UIViewController, MKMapViewDelegate {
//    var route: MKRoute? = nil
    var mapView: MKMapView?
    
    @IBOutlet weak var directionName: UILabel!
    
    @IBOutlet weak var directionTime: UILabel!
    
    @IBOutlet weak var endBtn: UIButton!
    
    @IBOutlet weak var detailsBtn: UIButton!
    
    @IBOutlet weak var overviewBtn: UIButton!
    
    var handleGetRouteInstruction: GetRouteInstruction? = nil
    
    var handleMoveSideMenu: MoveSideMenu? = nil
    
    @objc func swipeLeftToRight(){
        handleMoveSideMenu?.showSideMenu()
        //        print("swipe")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("in direction")
        let swiftLeftToRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftToRight))
        swiftLeftToRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swiftLeftToRight)
        ViewController.fpc.move(to: .half, animated: true)
        endBtn.layer.cornerRadius = 13
        detailsBtn.layer.cornerRadius = 20
        overviewBtn.layer.cornerRadius = 20
        directionName.text = "To " + (MapProperty.selectedPin?.name)!
        var minutes = Int(ceil(MapProperty.chosenRoute!.expectedTravelTime/60))
        directionTime.text = convertMinutesToExpectedTime(minutes: minutes)
        for overlay in mapView!.overlays{
            if(!isFriendsOverlay(overlay: overlay)){
                mapView!.removeOverlay(overlay)
            }
        }
        MapProperty.overlayColor = ViewController.directionVc.color[0]
        mapView!.addOverlay(MapProperty.chosenRoute!.polyline, level: .aboveRoads)
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        print("in direction")
        ViewController.fpc.move(to: .half, animated: true)
        endBtn.layer.cornerRadius = 13
        for overlay in mapView!.overlays{
            if(!isFriendsOverlay(overlay: overlay)){
                mapView!.removeOverlay(overlay)
            }
        }
        MapProperty.overlayColor = ViewController.directionVc.color[0]
        mapView!.addOverlay(MapProperty.chosenRoute!.polyline, level: .aboveRoads)
    }
    
    
    @IBAction func detailsTap(_ sender: Any) {
        handleGetRouteInstruction!.getRouteInstruction()
    }
    
    @IBAction func overviewTap(_ sender: Any) {
        print("overview tap")
        let rekt = MapProperty.chosenRoute!.polyline.boundingMapRect
        self.mapView?.setRegion(MKCoordinateRegion(rekt), animated: true)
        ViewController.fpc.move(to: .tip, animated: true)
    }
    
    @IBAction func exitTap(_ sender: Any) {
        print("exit tap")
        MapProperty.chosenRoute = nil
        MapProperty.selectedPin = nil
        let alert = UIAlertController(title: "Exit route", message: "Are you sure to exit the route?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
            print(action.title)
            Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)/destination").setValue(nil)
            self.deleteUserAnnotation()
            self.deleteUserOverlay()
            ViewController.fpc.set(contentViewController: ViewController.searchVC)
            ViewController.fpc.move(to: .half, animated: true)
            
            //            self.launchMissile()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
            print(action.title)
        }))
        self.present(alert, animated: true, completion: nil)
    }
 
    func isFriendsDestinationAnnotation(annotation: MKAnnotation) -> Bool{
        for friendAnnotation in UserProperty.friendDestinationAnnotation.values{
            if (annotation.isEqual(friendAnnotation)){
                return true
            }
        }
        return false
    }
    
    
    func convertMinutesToExpectedTime(minutes: Int) -> String{
        let hours = Int(minutes/60)
        let days = Int(hours/24)
        if(days != 0){
            return "\(String(days)) day \(String(hours - days*24)) hr"
        }
        else if (hours != 0){
            return "\(String(hours)) hr \(String((minutes - 60 * hours))) min"
        }
        else {
            return "\(String((minutes))) min"
        }
    }
    
    func isFriendsOverlay(overlay: MKOverlay) -> Bool{
        for friendOverlay in UserProperty.friendOverlays.values{
            if (overlay.isEqual(friendOverlay)){
                return true
            }
        }
        return false
    }
    
    func deleteUserOverlay(){
        for overlay in mapView!.overlays{
            if(!isFriendsOverlay(overlay: overlay)){
                mapView!.removeOverlay(overlay)
            }
        }
    }
    
    func isFriendsAnnotation(annotation: MKAnnotation) -> Bool{
        for friendAnnotation in UserProperty.friendDestinationAnnotation.values{
            if (annotation.isEqual(friendAnnotation)){
                return true
            }
        }
        return false
    }
    
    func deleteUserAnnotation(){
        for annotation in mapView!.annotations{
            guard let newAnnotation = annotation as? Location else{
                if(!isFriendsAnnotation(annotation: annotation)){
                    mapView!.removeAnnotation(annotation)
                }
                continue
            }
        }
    }
    
}
