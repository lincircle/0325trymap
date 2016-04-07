//
//  Message.swift
//  0325trymap
//
//  Created by cosine on 2016/3/25.
//  Copyright © 2016年 Lin Circle. All rights reserved.
//

import Foundation
import CoreData

class Message: NSManagedObject{
    
    @NSManaged var message:String
    @NSManaged var latitude:Double
    @NSManaged var longitude:Double
    @NSManaged var date:NSDate
    @NSManaged var angle:Double
    
}
