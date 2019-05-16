//
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FloatingPanel
import Firebase
import AlamofireImage
import Alamofire
import CoreLocation

protocol GetDirection {
    func getDirection(destinationPlaceMark:MKPlacemark, transportType: MKDirectionsTransportType)
}

protocol GetRouteInstruction {
    func getRouteInstruction()
}

protocol MoveSideMenu {
    func showSideMenu()
    func hideSideMenu()
}

protocol MoveToChatView {
    func moveToChatView()
}


class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    
    // Panel class variable
    static var fpc: FloatingPanelController!
    static var searchVC: SearchPanelViewController!
    static var directionVc: DirectionPanelViewController!
    static var inDirectionVc: InDirectionPanelViewController!
    static var friendVc: FriendsPanelViewController!
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var headingImageView: UIImageView?
    
    var userHeading: CLLocationDirection?
    
    var cameraHeading: CLLocationDirection?
    
    @IBOutlet weak var currLocationAndFriendBox: UIView!
    
    @IBOutlet weak var currentPositionBtn: UIButton!
    
    @IBOutlet weak var friendBtn: UIButton!
    
    // side menu property
    @IBOutlet weak var sideMenu: UIView!
    
    @IBOutlet weak var avatarInMenu: UIImageView!
    
    @IBOutlet weak var editProfileView: UIView!
    
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    @IBOutlet weak var sideMenuUserNameLabel: UILabel!
    
    @IBAction func editInfo(_ sender: Any) {
        performSegue(withIdentifier: "InfoSegue", sender: nil)
    }
    
    
    let menuItems = ["History", "Setting", "Help", "About us", "Log out"]
    
    let menuItemsImage = ["historyIcon", "settingIcon", "helpIcon", "aboutUsIcon", "logoutIcon"] 
    
//    @IBOutlet weak var logoutBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        mapView.register(FriendAnnotation.self  ,
                         forAnnotationViewWithReuseIdentifier: "friendLocation")
        
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        friendBtn.isHidden = true
        currLocationAndFriendBox.layer.cornerRadius = 15.0
        currLocationAndFriendBox.layer.borderColor = UIColor.lightGray.cgColor
        currLocationAndFriendBox.layer.borderWidth = 0.5;
        currentPositionBtn.layer.cornerRadius = 10.0
        friendBtn.layer.cornerRadius = 10.0
        
//        logoutBtn.layer.cornerRadius = 13.0
//        logoutBtn.layer.borderWidth = 1
//        logoutBtn.layer.borderColor = UIColor.red.cgColor
//avatarInMenu.frame.width/2
        avatarInMenu.layer.cornerRadius = 20
        avatarInMenu.translatesAutoresizingMaskIntoConstraints = false
        avatarInMenu.contentMode = .scaleAspectFill

        
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            locationManager.allowsBackgroundLocationUpdates = true
            mapView.setUserTrackingMode(.follow, animated: true)
        }

        
        ViewController.fpc = FloatingPanelController()
        ViewController.fpc.delegate = self
        ViewController.fpc.surfaceView.backgroundColor = .clear
        ViewController.fpc.surfaceView.cornerRadius = 12.0
        ViewController.fpc.surfaceView.shadowHidden = false
        
        ViewController.searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchPanelViewController") as? SearchPanelViewController
        ViewController.searchVC.handleMapSearchDelegate = self
        ViewController.searchVC.handleMoveSideMenu = self

        ViewController.directionVc = storyboard?.instantiateViewController(withIdentifier: "DirectionPanelViewController") as? DirectionPanelViewController
        ViewController.directionVc.handleMapSearchDelegate = self
        ViewController.directionVc.mapView = mapView
        ViewController.directionVc.handleMoveSideMenu = self
        
        ViewController.inDirectionVc = storyboard?.instantiateViewController(withIdentifier: "InDirectionPanelViewController") as? InDirectionPanelViewController
        ViewController.inDirectionVc.mapView = mapView
        ViewController.inDirectionVc.handleGetRouteInstruction = self
        ViewController.inDirectionVc.handleMoveSideMenu = self
        
        ViewController.friendVc = storyboard?.instantiateViewController(withIdentifier: "FriendsPanelViewController") as? FriendsPanelViewController
        ViewController.friendVc.handleMoveSideMenu = self
        ViewController.friendVc.mapView = mapView
        ViewController.friendVc.handleMoveToChatView = self

        ViewController.fpc.set(contentViewController: ViewController.searchVC)
//        ViewController.fpc.track(scrollView: ViewController.searchVC.tableView)
 
    }
    
    //Side menu action
    @objc func swipeRightToLeft(){
        hideSideMenu()
    }

    func showHideFriendLocation() {
        // remove all friend annotation, route if user turn off the mode in setting
        if(MapProperty.showFriendLocations == false){
            /// detele friend annotation
            self.mapView.removeAnnotations(Array( UserProperty.friendLocations.values))
            self.mapView.removeAnnotations(Array( UserProperty.friendDestinationAnnotation.values))
            self.mapView.removeOverlays(Array( UserProperty.friendOverlays.values))
        }
            // add all friend annotation if user turn on the mode in setting
        else{
            self.mapView.addAnnotations(Array( UserProperty.friendLocations.values))
            self.mapView.addAnnotations(Array( UserProperty.friendDestinationAnnotation.values))
            self.mapView.addOverlays(Array( UserProperty.friendOverlays.values))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Add FloatingPanel to a view with animation.
        print("View appear")
        if(UserProperty.currentUser == nil){
            checkIfUserIsLoggedIn()
        }
        showHideFriendLocation()
        ViewController.fpc.addPanel(toParent: self, animated: true)
        ViewController.searchVC.searchBar.delegate = self
        locationManager.startUpdatingHeading()
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    func checkIfUserIsLoggedIn(){
        if(Auth.auth().currentUser?.uid == nil){
            print("nil uid")
            handleLogout()
        }
        else{
//            ViewController.friendVc = storyboard?.instantiateViewController(withIdentifier: "FriendsPanelViewController") as? FriendsPanelViewController
            // get current user
            let uid = Auth.auth().currentUser!.uid
            print("current user: ",uid)
            Database.database().reference().child("users").observe(.value, with: {(snapshot) in
                print("get all users: ",snapshot.value);
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    for (userId, userInfo) in dictionary{
//                        //skip current user
                        if (userId == uid){
                            continue;
                        }
                        let userEmail = (dictionary[userId]!)["email"] as? String
                        let userName = (dictionary[userId]!)["name"] as? String
                        let userPhone = (dictionary[userId]!)["phone"] as? String
                        let profileImageUrl = (dictionary[userId]!)["profileImageUrl"] as? String
                        let user = User(id: userId, email: userEmail!, name: userName!, phone: userPhone!, profileImageUrl: profileImageUrl!)
                        print("current creating user: ",user)
                        UserProperty.users[userId] = user
                        
                        Alamofire.request(profileImageUrl!).responseImage { response in
                            if let image = response.result.value {
                              UserProperty.users[userId]!.avatar = image
                            }
                        }
                        
                        UserProperty.userIdList.insert(userId)
                    }
                    print("user id list \(UserProperty.userIdList)")
                    
                }
            }, withCancel: nil)
            
            Database.database().reference().child("users").child(uid).observe(.value, with: {(snapshot) in
                print(snapshot);
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    var user = User(id: uid, email: (dictionary["email"] as? String)!, name: (dictionary["name"] as? String)!, phone: (dictionary["phone"] as? String)!, profileImageUrl: (dictionary["profileImageUrl"] as? String)!)
                    UserProperty.currentUser = user
                    self.friendBtn.isHidden = false
                    print("user id: \(user.id)")
                    self.sideMenuUserNameLabel.text = (dictionary["name"] as? String)!
                    Alamofire.request((dictionary["profileImageUrl"] as? String)!).responseImage { response in
                        if let image = response.result.value {
//                            UserProperty.currentUser?.avatar = image
                            self.avatarInMenu.image = image
                            UserProperty.currentUser!.avatar = image
                        }
                    }
                    self.loadInitialData()
//                    self.userName.text = "hello " + name!
                }
            }, withCancel: nil)
        }
    }
    
    func handleLogout() {
        //        let loginController = LoginController()
        //        present(loginController, animated: true, completion: nil)
        
        do {
            try Auth.auth().signOut()
            
            performSegue(withIdentifier: "LoginSegue", sender: nil)
            // reset if user Log out
//            if(UserProperty.currentUser != nil){
//                Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)/destination").setValue(nil)
//            }
            ViewController.searchVC.searchBar.text = ""
            ViewController.fpc.set(contentViewController: ViewController.searchVC)
            
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
            
            MapProperty.overlayColor = nil
            MapProperty.selectedPin = nil
            MapProperty.chosenRoute = nil
            MapProperty.directionSteps = []
            MapProperty.transportType = .automobile
            avatarInMenu.image = nil
            
            UserProperty.friendDestinationAnnotation = [String: MKPointAnnotation]()
            UserProperty.friendOverlays = [String: MKOverlay]()
            UserProperty.userIdList = []
            UserProperty.users = [String: User]()
            UserProperty.currentUser = nil
            UserProperty.friendLocations = [String: Location]()
            friendBtn.backgroundColor = UIColor.lightGray
            friendBtn.isHidden = true
            hideSideMenu()
            
            
        } catch let logOutError{
            print(logOutError)
        }
        
        print("log out")
    }
    
//    @IBAction func logoutTap(_ sender: Any) {
//        handleLogout()
//    }
    

    @IBAction func currentLocationTap(_ sender: Any) {
        let sourceCoordinates = locationManager.location?.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: sourceCoordinates!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func friendsListTap(_ sender: Any) {
        print("Friend list tap")
        if ((friendBtn.backgroundColor?.isEqual(UIColor.lightGray))!){
            // change track so that contentViewcontroller will coresponse to friend table view
            ViewController.fpc.track(scrollView: ViewController.searchVC.tableView)
            print(ViewController.fpc.scrollView!)
            ViewController.fpc.set(contentViewController: ViewController.friendVc)
            if(ViewController.fpc.position != .tip){
                ViewController.friendVc.friendTableView.alpha = 1
            }
            friendBtn.backgroundColor = UIColor(hue: 0.5472, saturation: 1, brightness: 0.91, alpha: 1.0)
        }
        else if ((friendBtn.backgroundColor?.isEqual(UIColor(hue: 0.5472, saturation: 1, brightness: 0.91, alpha: 1.0) ))!){
            friendBtn.backgroundColor = UIColor.lightGray
            
            // change track so that contentViewcontroller will coresponse to search table view
            
            print(ViewController.fpc.scrollView!)
            if(MapProperty.chosenRoute != nil){
                ViewController.fpc.set(contentViewController: ViewController.inDirectionVc)
            }
            else if(MapProperty.selectedPin != nil){
                ViewController.fpc.set(contentViewController:  ViewController.directionVc)
            }
            else {
                ViewController.fpc.set(contentViewController:  ViewController.searchVC)
            }
            
        }
        else{
            ViewController.fpc.set(contentViewController: ViewController.friendVc)
            friendBtn.backgroundColor = UIColor(hue: 0.5472, saturation: 1, brightness: 0.91, alpha: 1.0)
        }
    }
    
}


// search bar function, update seach result while searching for location
extension ViewController{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        ViewController.fpc.move(to: .half, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        ViewController.searchVC.tableView.alpha = 1.0
        ViewController.fpc.move(to: .full, animated: true)
    }
    
    func updateSearchResult(){
        if (ViewController.searchVC.searchBar.text!.count % 2 != 0){
            return
        }
        guard
            let mapView = mapView,
            let searchBarText = ViewController.searchVC.searchBar.text else {return }
        print(searchBarText)
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            ViewController.searchVC.matchingItems = response.mapItems
            ViewController.searchVC.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateSearchResult()
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResult()
    }
}

// floating panel set up
extension ViewController {
    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            ViewController.fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            ViewController.fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            ViewController.fpc.surfaceView.borderWidth = 0.0
            ViewController.fpc.surfaceView.borderColor = nil
            return nil
        }
    }
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
//        let y = vc.surfaceView.frame.origin.y
//        let tipY = vc.originYOfSurface(for: .tip)
//        if y > tipY - 44.0 {
//            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
//            self.searchVC.tableView.alpha = progress
//        }
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            if (ViewController.fpc.contentViewController == ViewController.searchVC){
                ViewController.searchVC.searchBar.showsCancelButton = false
                ViewController.searchVC.searchBar.resignFirstResponder()
            }
            if (ViewController.fpc.contentViewController == ViewController.friendVc){
                ViewController.friendVc.friendSearchBar.showsCancelButton = false
                ViewController.friendVc.friendSearchBar.resignFirstResponder()
            }
            else if(ViewController.fpc.contentViewController == ViewController.directionVc){
                // impletation
            }
        }
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition != .full {
        }
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if (ViewController.fpc.contentViewController == ViewController.searchVC){
                            if targetPosition == .tip {
                                ViewController.searchVC.tableView.alpha = 0.0
                            } else {
                                ViewController.searchVC.tableView.alpha = 1.0
                            }
                        }
                        if (ViewController.fpc.contentViewController == ViewController.friendVc){
                            if targetPosition == .tip {
                                ViewController.friendVc.friendTableView.alpha = 0.0
                            } else {
                                ViewController.friendVc.friendTableView.alpha = 1.0
                            }
                        }
                        else if(ViewController.fpc.contentViewController == ViewController.directionVc){
                            // impletation
                        }
        }, completion: nil)
    }
}


// extention for map configuration.
extension ViewController{
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        //        print("will")
        cameraHeading = mapView.camera.heading
        //        print("cameraHeading:  \(cameraHeading)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(userHeading != nil && cameraHeading != mapView.camera.heading){
            var newHeading = userHeading! - mapView.camera.heading
            print(newHeading)
            print(userHeading!)
            print(mapView.camera.heading)
            updateHeadingRotation(heading : newHeading)
            cameraHeading = mapView.camera.heading
        }
    }
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingImageView == nil {
            let image = UIImage(named: "arrow.png")!
            headingImageView = UIImageView(image: image)
            headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - image.size.width)/2, y: (annotationView.frame.size.height - image.size.height)/2, width: image.size.width, height: image.size.height)
            annotationView.insertSubview(headingImageView!, at: 0)
            headingImageView!.isHidden = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else if (annotation is Location)  {
            let reuseId = "friendLocation"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            pinView?.annotation = annotation
            return pinView
        }
        else {
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            pinView?.annotation = annotation
            return pinView
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        let heading = (newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading)
        userHeading = heading
        updateHeadingRotation(heading: heading - mapView.camera.heading)
    }
    
    func updateHeadingRotation(heading: CLLocationDirection) {
        guard headingImageView != nil else {return}
        headingImageView!.isHidden = false
        let rotation = CGFloat((heading)/180 * Double.pi)
        headingImageView!.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    
    // check if finish route or out of route here
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard (UserProperty.currentUser?.id) != nil else{return}
        
        let currentLocation = locationManager.location!
        print(currentLocation.coordinate)
        
        Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)").updateChildValues(["lat": currentLocation.coordinate.latitude, "lon": currentLocation.coordinate.longitude])
        
        
        if(MapProperty.selectedPin != nil && (ViewController.fpc.contentViewController?.isEqual(ViewController.inDirectionVc))!){
            let destinationLocation = MapProperty.selectedPin!.location
            let distanceInMeters = currentLocation.distance(from: destinationLocation!)
            print("distance: " )
            print(distanceInMeters)
            if (distanceInMeters <= 30){
                print("Finish route")
                let alert = UIAlertController(title: "Finish route", message: "Do you want to save the route to your history?", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
                    self.deleteUserAnnotation()
                    self.deleteUserOverlay()
                    // implement later
                    // **************implement save history
                    // **************implement save history
                    // **************implement save history
                    // **************implement save history
                    // **************implement save history
                    // **************implement save history
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: {action in
                    self.deleteUserAnnotation()
                    self.deleteUserOverlay()
                }))
                
                Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)/destination").setValue(nil)
                self.present(alert, animated: true, completion: nil)
                MapProperty.chosenRoute = nil
                MapProperty.selectedPin = nil
                ViewController.fpc.set(contentViewController: ViewController.searchVC)
            }
            // remomve route, and destination from memory
            // check if out of route
            else {
                var smallestDistanceInMeters: Double = 1000000000;
                // get all points of route
                for step in MapProperty.chosenRoute!.steps{
                    let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: step.polyline.pointCount)
                    step.polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, step.polyline.pointCount))
                    
                    // only get half of number of points
                    for i in 0..<step.polyline.pointCount {
                        if (i%3 == 0){
                             let pointCoordinate = CLLocation(latitude: coordsPointer[i].latitude, longitude: coordsPointer[i].longitude)
                            let distance = currentLocation.distance(from: pointCoordinate)
                            if (smallestDistanceInMeters > Double(distance)){
                                smallestDistanceInMeters = Double(distance)
                            }
                        }
                    }
                }
                if (smallestDistanceInMeters > 500){
                    let alert = UIAlertController(title: "Out of route", message: "You are currently out of the initial route. Do you want to start new route?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {action in
                        print(action.title!)
                        ViewController.directionVc.routes = []
                        ViewController.directionVc.directionTableView.reloadData()
                        self.getDirection(destinationPlaceMark: MapProperty.selectedPin!, transportType: MapProperty.transportType)
                        Database.database().reference(withPath: "Locations/\(UserProperty.currentUser!.id)/destination").setValue(nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: {action in
                        // implement later *****
                        // implement later *****
                        // implement later *****
                        // implement later *****
                        // implement later *****
                        // => if user dismiss, nerver display again
                        print(action.title)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
//                smallestDistanceInMeters = 501
                print("smallest distance: \(smallestDistanceInMeters)" )
            }
        }
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as UIViewController
//        if segue.identifier == "chatSegue" {
//            destinationVC.title = "friend...."
//            destinationVC.user = Auth.auth().currentUser!.uid
//        }
//    }
}


// extension getdirection protocol.
extension ViewController: GetDirection {
    
    func getDirection(destinationPlaceMark:MKPlacemark, transportType: MKDirectionsTransportType){
        ViewController.searchVC.searchBar.endEditing(true)
//        ViewController.fpc.move(to: .tip, animated: true)
        ViewController.searchVC.tableView.alpha = 0.0
        
        deleteUserOverlay()
        deleteUserAnnotation()

        MapProperty.selectedPin = destinationPlaceMark
        // clear existing annotatio
        
        deleteUserOverlay()
//        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = destinationPlaceMark.coordinate
        annotation.title = destinationPlaceMark.name
        if let city = destinationPlaceMark.locality,
            let state = destinationPlaceMark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        let sourceCoordinates = locationManager.location?.coordinate
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        //        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destinationPlaceMark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = transportType
        directionRequest.requestsAlternateRoutes = true
        //
        let direction = MKDirections(request: directionRequest)
        direction.calculate(completionHandler: {
            response, error in
            guard let response = response else{
                if let error = error{
                    print(error)
                }
                return
            }
            
            var routes = response.routes
            ViewController.directionVc.routes = routes
            
            ViewController.directionVc.directionTableView.reloadData()
            for i in stride(from: routes.count - 1, through: 0, by: -1){
                if(i > 2){ break}
                print(i)
                if(i == 0){
                    MapProperty.overlayColor = UIColor(red: 50/255, green: 138/255, blue: 239/255, alpha: 1.0)
                }
                else if (i == 1){
                    MapProperty.overlayColor = UIColor(red:0.66, green:0.73, blue:0.89, alpha:1.0)
                }
                else if (i == 2){
                    MapProperty.overlayColor = UIColor(red:0.66, green:0.73, blue:0.89, alpha:1.0)
                }
                
                self.mapView.addOverlay(routes[i].polyline, level: .aboveRoads)
            }
            let rekt = routes[0].polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
        })
        
        ViewController.fpc.set(contentViewController: ViewController.directionVc)
        ViewController.fpc.track(scrollView: ViewController.directionVc.directionTableView)
    }
    
    
}

// extention get route instruction.
extension ViewController:  GetRouteInstruction{
    func getRouteInstruction() {
        locationManager.stopUpdatingHeading()
        performSegue(withIdentifier: "stepsSegue", sender: nil)
    }
}

extension ViewController:  MoveToChatView{
    func moveToChatView() {
        locationManager.stopUpdatingHeading()
        performSegue(withIdentifier: "chatSegue", sender: nil)
    }
}

extension ViewController: MoveSideMenu{
    func showSideMenu() {
        if(sideMenu.isHidden == true){
            print("Show side menu")
            sideMenu.isHidden = false
            self.mapView.isZoomEnabled = false;
            self.mapView.isScrollEnabled = false;
            self.mapView.isUserInteractionEnabled = false;
            ViewController.fpc.move(to: .hidden, animated: true)
            
            let swiftRightToLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightToLeft))
            swiftRightToLeft.direction = UISwipeGestureRecognizer.Direction.left
            view.addGestureRecognizer(swiftRightToLeft)
        }
    }
    
    func hideSideMenu() {
        if(sideMenu.isHidden == false){
            print("Hide side menu")
            sideMenu.isHidden = true
            ViewController.fpc.move(to: .half, animated: true)
            self.mapView.isZoomEnabled = true;
            self.mapView.isScrollEnabled = true;
            self.mapView.isUserInteractionEnabled = true;
        }
    }
}

// load annotation to be shown on map
extension ViewController {
    func loadInitialData() { Database.database().reference().child("friendships").child(UserProperty.currentUser!.id).observe(.value, with: {(snapshot) in
            print(snapshot);
            if let dictionary = snapshot.value as? [String: AnyObject]{
                print("friendships:")
//                dictionary.removeValue(forKey: <#T##String#>)
                UserProperty.currentUser!.friendList = []
                dictionary.forEach({(key,value) in
                    print(key)
                    if(key != "self"){
                        UserProperty.currentUser!.friendList.insert(key)
                        print(UserProperty.currentUser!.friendList.count)
                    }
                })
                if (UserProperty.currentUser!.friendList.count != UserProperty.friendLocations.keys.count){
                    for key in UserProperty.friendLocations.keys{
                        if (!UserProperty.currentUser!.friendList.contains(key)){
                            UserProperty.friendLocations.removeValue(forKey: key)
                        }
                    }
                    for annotation in self.mapView.annotations{
                        guard let friendAnnotation = annotation as? Location
                            else {continue}
                        self.mapView.removeAnnotation(friendAnnotation)
                    }
                    self.mapView.addAnnotations(Array( UserProperty.friendLocations.values))
                }
            }
            
            
            if (UserProperty.currentUser!.friendList.count != 0){
                for friendId in UserProperty.currentUser!.friendList{
                    print(UserProperty.currentUser!.friendList); Database.database().reference().child("Locations").child(friendId).observe(.value, with: {(snapshot) in
                        if(UserProperty.currentUser == nil){
                            return
                        }
                        if (friendId == UserProperty.currentUser!.id){
                            return
                        }
                        print(snapshot);
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            
                            print("asdasdasdas")
                            print("\(dictionary["lat"]!): \(dictionary["lon"]!)")
                            let lat = Double(dictionary["lat"]! as! NSNumber)
                            let lon = Double(dictionary["lon"]! as! NSNumber)
                       
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            
                            if( UserProperty.friendLocations[friendId] == nil){
                                let location = Location(title: friendId, locationName: "currentLocation", coordinate: coordinate, avatar: UserProperty.users[friendId]!.profileImageUrl )
                                UserProperty.friendLocations[friendId] = location
                            }
                            
                            else {
                                UserProperty.friendLocations[friendId]?.coordinate = coordinate
                            }
                            
                            if(UserProperty.friendLocations[friendId]!.avatar != UserProperty.users[friendId]!.profileImageUrl){
                                UserProperty.friendLocations[friendId]!.avatar = UserProperty.users[friendId]!.profileImageUrl
                            }
                            
                            print(friendId)
                            for annotation in self.mapView.annotations{
                                guard let friendAnnotation = annotation as? Location
                                    else {continue}
                                self.mapView.removeAnnotation(friendAnnotation)
                            }
                            print(MapProperty.showFriendLocations)
                            if(MapProperty.showFriendLocations == true){
                                self.mapView.addAnnotations(Array( UserProperty.friendLocations.values))
                            }
                            
                            
                            /// friend routes
                            guard let destinationCoordinate = dictionary["destination"]
                                else {
                                    print(self.mapView.overlays.count)
                                    guard let friendOverlay = UserProperty.friendOverlays[friendId] else{return}
//                                    for overlay in self.mapView.overlays{
//                                        if(overlay.isEqual(friendOverlay)){
//                                            self.mapView.removeOverlay(overlay)
//                                            UserProperty.friendOverlays[friendId] = nil
//                                        }
//                                    }
                                    self.mapView.removeOverlay(UserProperty.friendOverlays[friendId]!)
                                    UserProperty.friendOverlays[friendId] = nil
                                    self.mapView.removeAnnotation(UserProperty.friendDestinationAnnotation[friendId]!)
                                    UserProperty.friendDestinationAnnotation[friendId] = nil
                                    return}
                            
                            
                            if(UserProperty.friendOverlays[friendId] != nil){
                                return
                            }
                            
                            print(UserProperty.friendOverlays[friendId])
                            print("destination")
                            let destinationLat = Double(destinationCoordinate["lat"]! as! NSNumber)
                            let destinationLon = Double(destinationCoordinate["lon"]! as! NSNumber)
                            let transportType = destinationCoordinate["transportType"]! as! Int
                            let routeName = destinationCoordinate["routeName"]! as! String
                            
                            let friendDestinationCoordinate = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLon)
                            
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = friendDestinationCoordinate
                            annotation.title = UserProperty.users[friendId]!.name + "'s destination"
                            
                            
                            if(UserProperty.friendDestinationAnnotation[friendId] == nil){
                                if(MapProperty.showFriendLocations == true){
                                    self.mapView.addAnnotation(annotation)
                                }
                                UserProperty.friendDestinationAnnotation[friendId] = annotation
                                print(self.mapView.annotations.count)
                                return
                            }
                            
                            let sourcePlaceMark = MKPlacemark(coordinate: coordinate)
                            let destPlactMark = MKPlacemark(coordinate: friendDestinationCoordinate)
                            
                            let sourceItem = MKMapItem(placemark: sourcePlaceMark)
                            let destItem = MKMapItem(placemark: destPlactMark)
                            
                            let directionRequest = MKDirections.Request()
                            directionRequest.source = sourceItem
                            directionRequest.destination = destItem
                            if(transportType == 1){
                                directionRequest.transportType = .automobile
                            }
                            else {
                                directionRequest.transportType = .walking
                            }
                            directionRequest.requestsAlternateRoutes = true
                            
                            let direction = MKDirections(request: directionRequest)
                            direction.calculate(completionHandler: {
                                response, error in
                                guard let response = response else{
                                    if let error = error{
                                        print(error)
                                    }
                                    return
                                }
                                let routes = response.routes
                                for route in routes{
                                    print(route.name)
                                    if (route.name == routeName){
                                        if(UserProperty.friendOverlays[friendId] != nil){
                                            return
                                        }
                                        self.mapView.addOverlay(routes[0].polyline, level: .aboveRoads)
                                        UserProperty.friendOverlays[friendId] = self.mapView.overlays.last
                                        self.mapView.removeOverlay(self.mapView.overlays.last!)
                                        if(MapProperty.showFriendLocations == true){
                                            self.mapView.addOverlay(routes[0].polyline, level: .aboveRoads)
                                        }
                                        print(self.mapView.overlays.count)
                                        break
                                    }
                                }
                            })
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
    }
    
    
}


extension ViewController{
    func isFriendsOverlay(overlay: MKOverlay) -> Bool{
        for friendOverlay in UserProperty.friendOverlays.values{
            if (overlay.isEqual(friendOverlay)){
                return true
            }
        }
        return false
    }
    
    func deleteUserOverlay(){
        for overlay in mapView.overlays{
            if(!isFriendsOverlay(overlay: overlay)){
                mapView.removeOverlay(overlay)
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
        for annotation in mapView.annotations{
            guard let newAnnotation = annotation as? Location else{
                if(!isFriendsAnnotation(annotation: annotation)){
                    mapView.removeAnnotation(annotation)
                }
                continue
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        if(isFriendsOverlay(overlay: overlay)){
            renderer.strokeColor = getRandomColor()
            renderer.lineWidth = 3.0
        }
        else {
            renderer.strokeColor = MapProperty.overlayColor
            renderer.lineWidth = 5.0
        }
        return renderer
    }
    
    
    func getRandomColor() -> UIColor{
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
}


