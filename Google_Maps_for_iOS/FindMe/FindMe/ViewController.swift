//
//  ViewController.swift
//  FindMe
//
//  Created by Yatheesan Chandreswaran on 4/25/17.
//  Copyright © 2017 Yatheesan. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var viewMap: GMSMapView!
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            // viewMap.isMyLocationEnabled = true
            viewMap.settings.myLocationButton = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        
        viewMap.camera = GMSCameraPosition.camera(withTarget: newLocation!.coordinate, zoom: 15.0)
        
        let marker = GMSMarker()
        marker.position = (newLocation?.coordinate)!
        marker.title = "Current Location"
        marker.snippet = "Location"
        marker.map = viewMap
        locationManager.stopUpdatingLocation()
    }

    @IBAction func changeMapType(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .normal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .terrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.viewMap.mapType = .hybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }

}

