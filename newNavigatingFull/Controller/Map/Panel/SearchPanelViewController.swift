//
//  SearchPanelViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/9/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit
import MapKit


class SearchPanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var matchingItems:[MKMapItem] = []
    
    var handleMapSearchDelegate:GetDirection? = nil
    
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
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.placeholder = "Search for a place or address"
        ViewController.searchVC.tableView.reloadData()
//        ViewController.directionVc.routes = []
//        let textField = searchBar.value(forKey: "_searchField") as! UITextField
//        textField.font = UIFont(name: textField.font!.fontName, size: 15.0)
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        ViewController.fpc.track(scrollView: tableView)
        ViewController.searchVC.tableView.reloadData()
        ViewController.directionVc.routes = []
        ViewController.directionVc.directionTableView?.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 10, *) {
            visualEffectView.layer.cornerRadius = 9.0
            visualEffectView.clipsToBounds = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell?
        cell?.textLabel?.text = matchingItems[indexPath.row].name
        cell?.detailTextLabel?.text = parseAddress(selectedItem: matchingItems[indexPath.row].placemark)
                print(cell?.detailTextLabel?.text)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        tableView.deselectRow(at: indexPath, animated: false)
        
        ViewController.directionVc.carBtn?.layer.backgroundColor = ViewController.directionVc.color[0].cgColor
        MapProperty.transportType = .automobile
        ViewController.directionVc.walkBtn?.layer.backgroundColor = UIColor.white.cgColor
        handleMapSearchDelegate?.getDirection(destinationPlaceMark: selectedItem, transportType: MapProperty.transportType)
//        dismiss(animated: true, completion: nil)
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}
