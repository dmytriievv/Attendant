//
//  MyInfoViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 4/8/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class MyInfoViewController: UIViewController {
    
    
    
    //MARK: Outlets
    
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var departmentNameLabel: UILabel!
    
    
    
    //MARK: Actions
    
    @IBAction func signOut(sender: UIButton) {
        KCSUser.activeUser().logout()
    }
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let workerName = KCSUser.activeUser().getValueForAttribute("Name") as! String
        let companyName = KCSUser.activeUser().getValueForAttribute("Company name") as! String
        let departmentName = KCSUser.activeUser().getValueForAttribute("Department name") as! String
        workerNameLabel.text = "My Name: \(workerName)"
        companyNameLabel.text = "Company Name: \(companyName)"
        departmentNameLabel.text = "Department Name: \(departmentName)"
    }
    
}
