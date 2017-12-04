//
//  LocationViewController.swift
//  FindMe
//
//  Created by Yatheesan Chandreswaran on 4/25/17.
//  Copyright © 2017 Yatheesan. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var currentLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: <#T##CLGeocodeCompletionHandler##CLGeocodeCompletionHandler##([CLPlacemark]?, Error?) -> Void#>)
        print("location = \(String(describing: manager.location?.coordinate.latitude))")
        print("location = \(String(describing: manager.location?.coordinate.longitude))")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}
