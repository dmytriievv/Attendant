//
//  Presence.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 6/8/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import Foundation

class Attendance: NSObject {    //all NSObjects in Kinvey implicitly implement KCSPersistable
    var entityId: String? //Kinvey entity _id
    var date: String?
    var time: String?
    var name: String?
    var departmentName: String?
    var managerId: String?
    
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId, //the required _id field
            "date" : "date",
            "time" : "time",
            "name" : "name",
            "departmentName" : "department name",
            "managerId" : "Manager Id"
            
        ]
        
    }
    
}