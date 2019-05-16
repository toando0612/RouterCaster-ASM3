//
//  SideMenuExtension.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/6/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath)
        cell.textLabel?.text = "        " + menuItems[indexPath.row]
        var imageView : UIImageView
        var label: UILabel = UILabel()
//        label.font = label.font.withSize(20)
//        label.text = "                   " + menuItems[indexPath.row]
        imageView  = UIImageView(frame: CGRect(x: 3, y: 5, width: 30, height: 30));
        imageView.image = UIImage(named: menuItemsImage[indexPath.row])
        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(menuItems[indexPath.row] == "Log out"){
            handleLogout()
        }
        else if(menuItems[indexPath.row] == "Setting"){
            performSegue(withIdentifier: "SettingSegue", sender: nil)
        }else if(menuItems[indexPath.row] == "Help"){
            performSegue(withIdentifier: "HelpSegue", sender: nil)
        }

    }
    
}
