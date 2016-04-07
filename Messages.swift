//
//  Messages.swift
//  0325trymap
//
//  Created by cosine on 2016/4/6.
//  Copyright © 2016年 Lin Circle. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation


class Messages: NSObject, NSFetchedResultsControllerDelegate {
    
    var list = [Message]()
    
    init(coordinate: CLLocationCoordinate2D, range: Double) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        let sortDescriptor = NSSortDescriptor(key: "date",ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //資料篩選
        
        let latitude_delta = range/111.0
        
        let longitude_delta = Messages.calculateDegreePerKmOfLongitudeAtLatitude(coordinate)*range
        
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
        
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext{
            
            let fetchResultController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: managedObjectContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            do {
                
                try fetchResultController.performFetch()
                
                self.list = fetchResultController.fetchedObjects as! [Message]
                
            }
            catch {
                
                print(error)
                
            }
            
        }
        
    }
    
    class func add(text:String, coordinate:CLLocationCoordinate2D, angle:Double? = nil) {
        
        //print("txt==" + text.text!)
        
        //print("緯度=" + String(location.coordinate.latitude))
        
        //print("經度=" + String(location.coordinate.longitude))
        
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var message: Message!
        
        //print("日期=" + dateFormatter.stringFromDate(date))
        
        //print(sw_btn.on)
        
        
        if let NSManagedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext{
            
            message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: NSManagedObjectContext) as! Message
            
            message.message = text
            message.latitude = coordinate.latitude
            message.longitude = coordinate.longitude
            message.date = date
            
            if let a = angle {
            
                message.angle = a
            
            }
            
            do
            {
                try NSManagedObjectContext.save()
            }
            catch
            {
                print(error)
                return
            }
        }

    }
    
    class func getNearby(coordinate: CLLocationCoordinate2D, range: Double) {
        
        
        
    }
    
    class func calculateDegreePerKmOfLongitudeAtLatitude(coordinate: CLLocationCoordinate2D) -> Double {
        
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
