//
//  DirectionPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/10/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit

class DirectionPanelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    
    @IBOutlet weak var destinationLabel: UILabel!
    
    @IBOutlet weak var carBtn: UIButton!
    
    @IBOutlet weak var walkBtn: UIButton!
    
    @IBOutlet weak var directionTableView: UITableView!
    
    var mapView: MKMapView?
    
    var handleMapSearchDelegate:GetDirection? = nil
    
    var color: [UIColor] = [UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0), UIColor(red:0.66, green:0.73, blue:0.89, alpha:1.0), UIColor(red:0.66, green:0.73, blue:0.89, alpha:1.0)]
    
    var routes: [MKRoute] = []
    
    @IBOutlet weak var xBtn: UIButton!
    
    var handleMoveSideMenu: MoveSideMenu? = nil
    
    @objc func swipeLeftToRight(){
        handleMoveSideMenu?.showSideMenu()
        //        print("swipe")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftLeftToRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftToRight))
        swiftLeftToRight.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swiftLeftToRight)
        directionTableView.delegate = self
        directionTableView.dataSource = self
        destinationLabel.text = "To " + MapProperty.selectedPin!.name!
        ViewController.searchVC.searchBar.text = ""
        ViewController.fpc.move(to: .half, animated: true)
        carBtn.layer.cornerRadius = 13
        walkBtn.layer.cornerRadius = 13
        xBtn.layer.cornerRadius = 13
        carBtn.layer.backgroundColor = color[0].cgColor
        walkBtn.layer.backgroundColor = UIColor.white.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        destinationLabel.text = "To " + MapProperty.selectedPin!.name!
        ViewController.searchVC.searchBar.text = ""
        ViewController.fpc.move(to: .half, animated: true)
    }
    
    
    
    @IBAction func tapExitDirection(_ sender: Any) {
        MapProperty.selectedPin = nil
        deleteUserOverlay()
        deleteUserAnnotation()
        ViewController.fpc.set(contentViewController: ViewController.searchVC)
    }
    
    @IBAction func tapCarBtn(_ sender: Any) {
        if(MapProperty.transportType != .automobile){
            carBtn.layer.backgroundColor = color[0].cgColor
            walkBtn.layer.backgroundColor = UIColor.white.cgColor
            ViewController.directionVc.routes = []
            ViewController.directionVc.directionTableView.reloadData()
            MapProperty.transportType = .automobile
            deleteUserOverlay()
            handleMapSearchDelegate?.getDirection(destinationPlaceMark: MapProperty.selectedPin!, transportType: .automobile)
        }
    }
    
    @IBAction func tapWalkBtn(_ sender: Any) {
        if (MapProperty.transportType != .walking){
            walkBtn.layer.backgroundColor = color[0].cgColor
            carBtn.layer.backgroundColor = UIColor.white.cgColor
            ViewController.directionVc.routes = []
            ViewController.directionVc.directionTableView.reloadData()
            MapProperty.transportType = .walking
            deleteUserOverlay()
            handleMapSearchDelegate?.getDirection(destinationPlaceMark: MapProperty.selectedPin!, transportType: .walking)
            ViewController.fpc.move(to: .half, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
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
    
    func convertDistanceUnit(distance: Double) -> String {
        var distanceInKm = distance / 1000
        if(MapProperty.distanceUnit == "km"){
            return "\(String(Int(distanceInKm))) km"
        }
        else{
            return "\(String(Double(round( 10 * distanceInKm * 0.62) / 10))) miles"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "direction", for: indexPath) as! DirectionTableCell
//        cell.directionName.text = routes[indexPath.row].name
        // change this later *****
        // change this later *****
        // change this later *****
//        cell.directionButton.backgroundColor = UIColor(red:0.24, green:0.89, blue:0.23, alpha:1.0)
        cell.route = routes[indexPath.row]
        cell.directionButton.layer.cornerRadius = 10.0
        var minutes = Int(ceil(routes[indexPath.row].expectedTravelTime/60))
        cell.directionTime.text = convertMinutesToExpectedTime(minutes: minutes)
        
        cell.directionDistance.text =  "\(convertDistanceUnit(distance: routes[indexPath.row].distance)) - \(routes[indexPath.row].name)"
        
        if(routes[indexPath.row].advisoryNotices.count == 0){
            if(indexPath.row == 0){
                cell.directionExtraInfo.text = "Fastest route"
            }
            else{
                cell.directionExtraInfo.text = "Alternative route"
            }
        }
        else{
            print(routes[indexPath.row].advisoryNotices)
            if(indexPath.row == 0){
                cell.directionExtraInfo.text = "\(routes[indexPath.row].advisoryNotices[0]) Fastest route"
            }
            else{
                cell.directionExtraInfo.text = "\(routes[indexPath.row].advisoryNotices[0]) Alternative route"
            }
        }

        cell.overlay = mapView!.overlays[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        for route in routes{
            if (!route.isEqual(routes[indexPath.row])){
                MapProperty.overlayColor = color[2]
                self.mapView!.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
        MapProperty.overlayColor = UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0)
        self.mapView!.addOverlay(routes[indexPath.row].polyline, level: .aboveRoads)
        ViewController.fpc.move(to: .tip, animated: true)
        let rekt = routes[indexPath.row].polyline.boundingMapRect
        
        self.mapView!.setRegion(MKCoordinateRegion(rekt), animated: true)
        print(self.mapView!.overlays.count)
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


