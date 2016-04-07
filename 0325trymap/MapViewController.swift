//
//  MapViewController.swift
//  0325trymap
//
//  Created by cosine on 2016/3/25.
//  Copyright © 2016年 Lin Circle. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    //var message: Message!
    
    @IBOutlet weak var map_view: MKMapView!
    
    @IBOutlet weak var submit: UIButton!
    
    @IBOutlet weak var text: UITextField!
    
    var location: MKUserLocation!
    
    //let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var sw_btn: UISwitch!
    
    @IBOutlet weak var angle_label: UILabel!
    
    
    private var angle: Double?
    
    private let _LOCATION_MANAGER = CLLocationManager()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _LOCATION_MANAGER.requestWhenInUseAuthorization()
        
        self.map_view.delegate = self
        
        self.map_view.showsUserLocation = true
        
        _LOCATION_MANAGER.delegate = self
        
        _LOCATION_MANAGER.startUpdatingHeading()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        print(userLocation.coordinate)
        
        self.location = userLocation
        
        map_view.centerCoordinate = userLocation.coordinate
        
        _zoom(userLocation.coordinate, animated: true)
        
    }
    
    @IBAction func submitdata(sender: AnyObject) {
        
        print("txt==" + text.text!)
        
        print("緯度=" + String(location.coordinate.latitude))
        
        print("經度=" + String(location.coordinate.longitude))
        
        if(sw_btn.on){
            
            Messages.add(text.text!, coordinate: location.coordinate, angle: angle)
            
        }
        else {
        
            Messages.add(text.text!, coordinate: location.coordinate)
            
        }
        
        
        self.text.text = ""
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        self.angle = (0 <= newHeading.headingAccuracy) ? round(newHeading.magneticHeading) : nil
        
        if let a = self.angle{
            
            self.angle_label.text = String(a)
        }
        
    }
    
    private func _zoom(coordinate: CLLocationCoordinate2D, animated: Bool) {
        
        var region = MKCoordinateRegion()
        
        region.center = coordinate
        
        //南北向每一公里的緯度度數與在赤道時東西向每一公里的經度度數
        let DEGREE_PER_KM_OF_LATITUDE_OR_LONGITUDE_AT_THE_EQUATOR = 1.0/111.0
        
        //將緯度換算為弧度
        let LATITUDE_RADIAN = abs(coordinate.latitude)*(acos(0.0)/90.0)
        
        //計算在該緯度時的半徑與赤道時的半徑比
        let RATIO_OF_RADIUS = cos(LATITUDE_RADIAN)
        
        //利用半徑比，計算出在該緯度時，每 1 公里的經度度數
        let DEGREE_PER_KM_OF_LONGITUDE_AT_LATITUDE = DEGREE_PER_KM_OF_LATITUDE_OR_LONGITUDE_AT_THE_EQUATOR/RATIO_OF_RADIUS

        region.span.latitudeDelta = DEGREE_PER_KM_OF_LATITUDE_OR_LONGITUDE_AT_THE_EQUATOR 
        
        region.span.longitudeDelta = DEGREE_PER_KM_OF_LONGITUDE_AT_LATITUDE
        
        /*
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
         */
        
        self.map_view.setRegion(region, animated: animated)
        
    }
    
    
    
    
}
