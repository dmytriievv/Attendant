//
//  DatePickerViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 6/13/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {
    
    
    
    //MARK: Outlets

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let convertedDate = dateFormatter.stringFromDate(currentDate)
        dateLabel.text = convertedDate
        datePicker.addTarget(self, action: #selector(SelectDateViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }

    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        dateLabel.text = strDate
    }
    
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectDepartment" {
            if let destination = segue.destinationViewController as? SelectDepartmentTableViewController {
                destination.date = dateLabel.text!
            }
        }
    }

}
