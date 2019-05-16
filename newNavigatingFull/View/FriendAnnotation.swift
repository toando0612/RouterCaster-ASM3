//
//  FriendAnnotation.swift
//  newNavigatingFull
//
//  Created by Nguyen Hoang Chuong on 5/4/19.
//  Copyright © 2019 Nguyen Hoang Chuong. All rights reserved.
//


import Foundation
import MapKit
import AlamofireImage
import Alamofire

class FriendAnnotation: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let location = newValue as? Location else {return}
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            tintColor = location.markerTintColor
            //            image = UIImage(named: "tam")
            rightCalloutAccessoryView = UIButton(type: .infoDark)
            let imageView = UIImageView(frame: CGRect(x: 0,y: 0,width: 25,height: 25))
            print(location.title)
            if(location.avatar != nil){
                Alamofire.request(location.avatar!).responseImage { response in
                    if let image = response.result.value {
                        imageView.image = image
                    }
                }
            }
            else{
                imageView.image = UIImage(named: "emailIcom")
            }
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.layer.masksToBounds = true
            self.addSubview(imageView)
//            sendSubviewToBack(imageView)
        }
    }
    
}



