//
//  DepartmentAttendanceTableViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 6/13/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class DepartmentAttendanceTableViewController: UITableViewController {

    //MARK: Properties
    
    var workers: NSMutableDictionary = [:]
    var userId = KCSUser.activeUser().userId
    var departmentName: String = ""
    var date = ""
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print (date)
        loadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkerCell", forIndexPath: indexPath)
        var workerLabels = workers.allKeys as! [String]
        cell.textLabel!.text = workerLabels[indexPath.row]
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workers.allValues as NSArray).count
    }
    
    
    
    //MARK: Functions
    
    func loadData() {
        let collection = KCSCollection(fromString: "Attendance", ofClass: Attendance.self)
        collection
        let store = KCSCachedStore(collection: collection, options: [ KCSStoreKeyCachePolicy : KCSCachePolicy.LocalFirst.rawValue ])
        let fiels = [ "name" ]
        let query1 = KCSQuery (onField: "date", usingConditional: .KCSIn, forValue: date)
        let query2 = KCSQuery (onField: "Manager Id", usingConditional: .KCSIn, forValue: userId)
        let query3 = KCSQuery (onField: "department name", usingConditional: .KCSIn, forValue: departmentName)
        let query4 = (query1 .queryByJoiningQuery(query2, usingOperator: .KCSAnd))
        let query = (query4 .queryByJoiningQuery(query3, usingOperator: .KCSAnd))
        

        store.group(
            fiels,
            reduce: KCSReduceFunction.AGGREGATE(),
            condition: query,
            completionBlock: { (valuesOrNil: KCSGroup!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                } else {
                    let data:NSMutableDictionary = NSMutableDictionary()
                    valuesOrNil.enumerateWithBlock({ (fieldValues: [AnyObject]!, value: AnyObject!, idx: UInt, stop:
                        UnsafeMutablePointer<ObjCBool>) -> Void in
                        let workerName = fieldValues[0] as! String
                        data[workerName] = value
                    })
                    self.workers = data
                    self.tableView.reloadData()
                }
            },
            progressBlock: nil
        )
    }
    
}
