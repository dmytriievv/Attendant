//
//  Workers.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 6/6/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import Foundation

class Worker : NSObject {    //all NSObjects in Kinvey implicitly implement KCSPersistable
    var entityId: String? //Kinvey entity _id
    var name: String?
    var departmentName: String?
    var managerId: String?
    
    
    override func hostToKinveyPropertyMapping() -> [NSObject : AnyObject]! {
        return [
            "entityId" : KCSEntityKeyId, //the required _id field
            "name" : "name",
            "departmentName" : "Department",
            "managerId" : "Manager Id"
        ]
        
    }
    
}