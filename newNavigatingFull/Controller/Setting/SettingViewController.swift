//
//  SettingViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/12/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var showFriendLocationSwitch: UISwitch!
    
    @IBOutlet weak var distanceUnitSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showFriendLocationSwitch.isOn = MapProperty.showFriendLocations
        if(MapProperty.distanceUnit == "km"){
            distanceUnitSegment.selectedSegmentIndex = 0
        }
        else {
            distanceUnitSegment.selectedSegmentIndex = 1
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeDistanceUnit(_ sender: UISegmentedControl) {
        if(distanceUnitSegment.selectedSegmentIndex == 0){
            MapProperty.distanceUnit = "km"
            print("Km")
        }
        else{
            MapProperty.distanceUnit = "mile"
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        showFriendLocationSwitch.isOn = MapProperty.showFriendLocations
    }
    
    @IBAction func showHideFriendLocation(_ sender: UISwitch) {
        if(sender.isOn){
            print("Implement show friend location")
            MapProperty.showFriendLocations = true
        }
        else{
            print("Implement hide friend location")
            MapProperty.showFriendLocations = false
        }
    }
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
