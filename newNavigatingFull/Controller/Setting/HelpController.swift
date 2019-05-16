//
//  HelpController.swift
//  newNavigatingFull
//
//  Created by Toan Do on 5/13/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class HelpController: UIViewController {
    
    @IBAction func backToSetting(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func watchRouting(_ sender: Any) {
        playRouting(name: "Routing")
    }
    @IBAction func watchChatting(_ sender: Any) {
        playRouting(name : "Chatting")

    }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }

    
    private func playRouting(name : String) {
        guard let path = Bundle.main.path(forResource: name, ofType:"mov") else {
            debugPrint("\(name).mov not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
}

extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

