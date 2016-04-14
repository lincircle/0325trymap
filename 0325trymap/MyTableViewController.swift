//
//  MyTableViewController.swift
//  0325trymap
//
//  Created by cosine on 2016/3/25.
//  Copyright © 2016年 Lin Circle. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class MyTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    private var _messages: Messages! = nil

    private var _location_manager = CLLocationManager()
    
    var current_location:CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _location_manager.requestWhenInUseAuthorization()
        
        _location_manager.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tableView.reloadData()
        
        _location_manager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let msg = _messages {
        
            return msg.list.count
        
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ListTableViewCell
        
        cell.txt.text = _messages.list[indexPath.row].message
        cell.latitude.text = String(_messages.list[indexPath.row].latitude)
        cell.longitude.text = String(_messages.list[indexPath.row].longitude)
        cell.date.text = String(_messages.list[indexPath.row].date)
        cell.angle.text = "角度：\(_messages.list[indexPath.row].angle)"
        
        return cell
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //_location_manager.stopUpdatingLocation()
        
        print(locations[0].coordinate)
        
        current_location = locations[0]
        
        _messages = Messages(coordinate: current_location.coordinate, range: 0.1)
        
        self.tableView.reloadData()
        
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
