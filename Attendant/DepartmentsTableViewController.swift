//
//  CompanyDepartmentsTableViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/26/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class DepartmentsTableViewController: UITableViewController {
    
    
    
    //MARK: Properties
    
    var departments: NSMutableDictionary = [:]
    var userId = KCSUser.activeUser().userId
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(DepartmentsTableViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        let companyName = KCSUser.activeUser().getValueForAttribute ("Company name") as! String?
        self.navigationItem.title = companyName! + " Departments"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WorkersTable" {
            if let destination = segue.destinationViewController as? WorkersTableViewController {
                let path = tableView.indexPathForSelectedRow
                let cell = tableView.cellForRowAtIndexPath(path!)
                destination.departmentName = (cell?.textLabel!.text!)!
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            self.performSegueWithIdentifier("WorkersTable", sender: self)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DepartmentCell", forIndexPath: indexPath)
        var departmentLabels = departments.allKeys as! [String]
        cell.textLabel!.text = departmentLabels[indexPath.row]
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (departments.allValues as NSArray).count
    }

    
    
    //MARK: Functions
    
    func loadData() {
        let collection = KCSCollection(fromString: "Departments", ofClass: Deparment.self) //load the data from the values collection
        let store = KCSCachedStore(collection: collection, options: [ KCSStoreKeyCachePolicy : KCSCachePolicy.LocalFirst.rawValue ])
        let fiels = [ "name" ]
        let query = KCSQuery (onField: KCSMetadataFieldCreator, usingConditional: .KCSIn, forValue: userId)
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
                        let departmentName = fieldValues[0] as! String
                        data[departmentName] = value
                    })
                    self.departments = data
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }
            },
            progressBlock: nil
        )
    }

    
    
    //MARK: Segues
    
    @IBAction func unwindToDepartmentsViewController(sender: UIStoryboardSegue) {
        loadData()
    }
    
}
