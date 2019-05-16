//
//  InstructionTableViewController.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 4/11/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import UIKit

class InstructionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MapProperty.chosenRoute!.steps.filter{$0.instructions != ""}.count
    }

    @IBAction func backtoMap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "directionStep", for: indexPath)
        cell.textLabel?.text = convertDistanceUnit (distance: Double(MapProperty.chosenRoute!.steps.filter{$0.instructions != ""}[indexPath.row].distance))
        cell.detailTextLabel?.text = MapProperty.chosenRoute!.steps.filter{$0.instructions != ""}[indexPath.row].instructions
        // Configure the cell...
        return cell
    }
    
    func convertMeterToKm(distance: Double) -> String{
        if(distance >= 1000){
            return "\(String(Double(round(10 * distance/1000)/10))) km"
        }
        else{
            return "\(Int(distance)) m"
        }
    }
    
    func convertDistanceUnit(distance: Double) -> String {
        var distanceInKm = distance / 1000
        if(MapProperty.distanceUnit == "km"){
            return convertMeterToKm(distance: distance)
        }
        else{
            return "\(String(Double(round( 100 * distanceInKm * 0.62) / 100))) miles"
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
