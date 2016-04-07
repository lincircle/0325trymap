//
//  MessageViewController.swift
//  0325trymap
//
//  Created by cosine on 2016/3/31.
//  Copyright © 2016年 Lin Circle. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MessageViewController: UIViewController, NSFetchedResultsControllerDelegate,
    CLLocationManagerDelegate {
    
    @IBOutlet weak var message_mapview: MKMapView!
    
    var messages:[Message] = []
    
    var fetchResultController: NSFetchedResultsController!
    
    private var _location_manager = CLLocationManager()
    
    var current_location:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _location_manager.requestWhenInUseAuthorization()
        
        _location_manager.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        _location_manager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        _location_manager.stopUpdatingLocation()
        
        print(locations[0].coordinate)
        
        current_location = locations[0]
        
        fetchNearbyMessages(current_location.coordinate, range: 0.025)
        
        pinAnnotations()
        
    }
    
    func pinAnnotations(){
        
        var annotations = [MKPointAnnotation]()
        
        for message in messages {
        
            let annotation = MKPointAnnotation()
            
            annotation.title = message.message
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: message.latitude, longitude: message.longitude)
            
            annotations.append(annotation)
            
        }
        
        self.message_mapview.showAnnotations(annotations, animated: true)
        self.message_mapview.selectAnnotation(annotations[0], animated: true)
        
        
    }
    
    func fetchNearbyMessages(coordinate: CLLocationCoordinate2D, range: Double) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        let sortDescriptor = NSSortDescriptor(key: "date",ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //資料篩選
        
        let latitude_delta = range/111.0
        
        let longitude_delta = calculateDegreePerKmOfLongitudeAtLatitude(coordinate)*range
        
        let min_latitude = coordinate.latitude - latitude_delta
        
        let max_latitude = coordinate.latitude + latitude_delta
        
        let min_longitude = coordinate.longitude - longitude_delta
        
        let max_longitude = coordinate.longitude + longitude_delta
        
        print("lat: \(min_latitude) ~ \(max_latitude)")
        
        print("lng: \(min_longitude) ~ \(max_longitude)")
        
        let subpredicates = [
            NSPredicate(format: "%lf < latitude", min_latitude),
            NSPredicate(format: "latitude < %lf ", max_latitude),
            NSPredicate(format: "%lf < longitude", min_longitude),
            NSPredicate(format: "longitude < %lf", max_longitude)
        ]
        
        fetchRequest.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: subpredicates)
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
            fetchResultController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                messages = fetchResultController.fetchedObjects as! [Message]
                //self.tableView.reloadData()
                
            }
            catch {
                
                print(error)
                
            }
            
        }
        
    }
    
    func calculateDegreePerKmOfLongitudeAtLatitude(coordinate: CLLocationCoordinate2D) -> Double {
        
        //南北向每一公里的緯度度數與在赤道時東西向每一公里的經度度數
        let DEGREE_PER_KM_OF_LATITUDE_OR_LONGITUDE_AT_THE_EQUATOR = 1.0/111.0
        
        //將緯度換算為弧度
        let LATITUDE_RADIAN = abs(coordinate.latitude)*(acos(0.0)/90.0)
        
        //計算在該緯度時的半徑與赤道時的半徑比
        let RATIO_OF_RADIUS = cos(LATITUDE_RADIAN)
        
        //利用半徑比，計算出在該緯度時，每 1 公里的經度度數
        let DEGREE_PER_KM_OF_LONGITUDE_AT_LATITUDE = DEGREE_PER_KM_OF_LATITUDE_OR_LONGITUDE_AT_THE_EQUATOR/RATIO_OF_RADIUS
        
        return DEGREE_PER_KM_OF_LONGITUDE_AT_LATITUDE
        
    }

}
