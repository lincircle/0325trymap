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
        /*
        let subpredicates = [
            NSPredicate(format: "%lf < latitude", min_latitude),
            NSPredicate(format: "latitude < %lf ", max_latitude),
            NSPredicate(format: "%lf < longitude", min_longitude),
            NSPredicate(format: "longitude < %lf", max_longitude)
        ]
        
        fetchRequest.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: subpredicates)
        
        */
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            
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
        
        /*
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
         */
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://leaf.ms/messages")!)
        request.HTTPMethod = "POST"
        
        var body: [NSObject : AnyObject] = [
            "message":text,
            "latitude":coordinate.latitude,
            "longitude":coordinate.longitude
        ]
        
        if let a = angle {
        
            //print("++++++++++++++++\(a)")
            
            body["_heading"] = a
            
        }
        
        request.HTTPBody = Messages.dictToJsonNSData(body)
        request.setValue("Bearer SA-Q9T8R_A-C~A-Q6Q7A~B+B~A-D8A-R.S+Q.A-C~A-S2R7R4A-T+/SA-R+S9R8A-C~A-Q2S.S9T_R2AS_Q1R3D9S4S1B.Q_B~Q1R6A+QAT7R0S0S9B+BQR8T1R5D9T1S9Q5B.R5A-D8A-R8R9R~S9Q_R9A-C~A-A.A.A.A.A.A.A.A.D9A.A.A.A.D9A.A.A.A.D9A.A.A.A.D9A.A.A.A.A.A.A.A.A.A.A.A.A-D8A-R.S+Q.R9A-C~A-T9T_Q-S9T8R9A-T+/Bh7A9S_A5j+B+S9D0w+i+R9z-z6z2x.A4C+A_T8D8z9R_h+D4T6R-CS6C6D3R8D5S3x1Q~xC.A9y+A_w9SA0y3D5g_j.z0C2h2S~C1i-R2z8jD1g~R_D_B-Q~A6g0h9C8Qg2i9C4j2y9C_A~i7T0j0g.w~i2T3g4B1R.h5S5Q6R~D4g9Q2B4x~z3y6A3B_i~w_i+g.z.D2Q3R4j3h9i-j0B9D~x5g9z2S.T8j9C.x4w0x0T8T5T4z7Q-y4", forHTTPHeaderField: "Authorization")
        
        let app_version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        
        let system_version = UIDevice.currentDevice().systemVersion
        
        let uuid = UIDevice.currentDevice().identifierForVendor!
        
        request.setValue("LeafMS/\(app_version) (iOS \(system_version); \(uuid.UUIDString))", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; version=1", forHTTPHeaderField: "Accept")
        
        let requestedHandler:(NSData?, NSURLResponse?, NSError?) -> Void = { (data, response, error) in
        
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            parseJsonData(data!)
            
        }
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: requestedHandler).resume()
        

    }
    
    class func parseJsonData(data: NSData) {
        
        let jsonResult: NSDictionary!
        
        do {
        
             jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            print(jsonResult)
            
            let jsonMessages = jsonResult["response"] as! NSDictionary
            print(jsonMessages)
            let jsonModel = jsonMessages["model"] as! NSDictionary
            print(jsonModel)
            let json = MessageJson()
            json.message = jsonModel["message"] as! String
            print(json.message)
            json.latitude = Double(jsonModel["latitude"] as! String)!
            print(json.latitude)
            json.longitude = Double(jsonModel["longitude"] as! String)!
            print(json.longitude)
            
            if let a = jsonModel["_heading"] as? Double {
                
                json.angle = a
            
            }
            
            let date1 = jsonModel["created_at"] as! String
            print(date1)
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
            json.date = dateFormatter.dateFromString(date1)
            
            print(json.date)
            
            var message: Message!
            
            if let NSManagedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext{
                
                message = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: NSManagedObjectContext) as! Message
                
                message.message = json.message
                message.latitude = json.latitude
                message.longitude = json.longitude
                message.date = json.date!
                
                if let a = json.angle {
                    
                    message.angle = a
                    
                }
                
                print("印出message物件\(message)")
                
                do {
                    
                    try NSManagedObjectContext.save()
                    print("存入core data")
                
                }
                catch {
                    
                    print(error)
                
                    return
                
                }
            }
        
        }
        catch _ {
            
            print("error")
            
        }
        
        print("Json資料解析進入core data")
        
    }
    
    class func dictToJsonNSData(dict:[NSObject:AnyObject]) -> NSData? {
        
        do {
            
            return try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
            
        }
        catch _ {
            
            return nil
            
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
