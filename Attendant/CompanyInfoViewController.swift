//
//  CompanyInfoViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/26/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class CompanyInfoViewController: UIViewController {
    
    
    
    //MARK: Properties
    
    var companyName = KCSUser.activeUser().getValueForAttribute("Company name") as! String
    var userId = KCSUser.activeUser().userId

    
    
    //MARK: Outlets

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var numberOfDepartmentsLabel: UILabel!
    @IBOutlet weak var numberOfWorkersLabel: UILabel!
    
    
    
    //MARK: Actions
    
    @IBAction func signOut(sender: UIButton) {
        KCSUser.activeUser().logout()
    }
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyNameLabel.text = "Company Name:  \(companyName)"
        departmentCount()
        workersCount()
    }
    
    
    
    //MARK: Functions
    
    func departmentCount() {
        let collection = KCSCollection(fromString: "Departments", ofClass: Deparment.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        let q = KCSQuery(onField: KCSMetadataFieldCreator, usingConditional: .KCSIn, forValue: userId)
        store.countWithQuery(q, completion: { (count: UInt, errorOrNil: NSError!) -> Void in
            self.numberOfDepartmentsLabel.text = "Number of Departments: \(count)"
        })
    }
    
    func workersCount() {
        let collection = KCSCollection(fromString: "Workers", ofClass: Worker.self)
        let store = KCSAppdataStore(collection: collection, options: nil)
        let q = KCSQuery(onField: KCSMetadataFieldCreator, usingConditional: .KCSIn, forValue: userId)
        store.countWithQuery(q, completion: { (count: UInt, errorOrNil: NSError!) -> Void in
            self.numberOfWorkersLabel.text = "Number of Workers: \(count)"
        })
    }

}