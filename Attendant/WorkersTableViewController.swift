//
//  WorkersTableViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/29/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class WorkersTableViewController: UITableViewController {
    
    
    
    //MARK: Properties
    
    var workers: NSMutableDictionary = [:]
    var userId = KCSUser.activeUser().userId
    var departmentName: String = ""
    

    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WorkersTableViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        self.navigationItem.title = departmentName + " Workers"
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRowAtIndexPath(indexPath) {
        }
        
    }
    
    
    
    //MARK: Functions
    
    func loadData() {
        let collection = KCSCollection(fromString: "Workers", ofClass: Worker.self)
        let store = KCSCachedStore(collection: collection, options: [ KCSStoreKeyCachePolicy : KCSCachePolicy.LocalFirst.rawValue ])
        let fiels = [ "name" ]
        let query1 = KCSQuery (onField: KCSMetadataFieldCreator, usingConditional: .KCSIn, forValue: userId)
        let query2 = KCSQuery (onField: "Department", usingConditional: .KCSIn, forValue: departmentName)
        let query = (query1 .queryByJoiningQuery(query2, usingOperator: .KCSAnd))
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
                    self.workers = data
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }
            },
            progressBlock: nil
        )
    }
    
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewWorker" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let newWorkerVC = navigationController.topViewController as! NewWorkerViewController
            newWorkerVC.departmentName = departmentName
                print (departmentName)
        }
    }
    
    @IBAction func unwindToWorkersViewController(sender: UIStoryboardSegue) {
        loadData()
        }
        
}



