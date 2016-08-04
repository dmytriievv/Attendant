//
//  NewWorkerViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/29/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class NewWorkerViewController: UIViewController, UITextFieldDelegate {
    
    
    
    //MARK: Properties
    
    let attributeDepartmentName = "Department name"
    let attributeManagerId = "Manager Id"
    let attributeCompanyName = "Company name"
    var attributeLongtitude = "Longtitude"
    var attributeLatitude = "Latitude"
    let attributeWorkerName = "Name"
    let attributeAccountType = "Account Type"
    var departmentName = ""
    var managerId = KCSUser.activeUser().userId
    var companyName = KCSUser.activeUser().getValueForAttribute ("Company name") as! String?
    var username = KCSUser.activeUser().username
    var passcode = KCSUser.activeUser().getValueForAttribute("Passcode") as! String?
    var companyLongtitude = KCSUser.activeUser().getValueForAttribute("Longtitude") as! String?
    var companyLatitude = KCSUser.activeUser().getValueForAttribute("Latitude") as! String?

    
    
    
    //MARK: Outlets
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var workerEmailField: UITextField!
    @IBOutlet weak var workerPasswordField: UITextField!
    @IBOutlet weak var workerNameField: UITextField!
    
    
    
    //MARK: Actions
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveButton(sender: UIBarButtonItem) {
        createWorkerAccount()
        saveWorker()
    }
    
    
    
    //MARK: Functions
    
    func createWorkerAccount () {
        KCSUser.userWithUsername(
            workerEmailField.text,
            password: workerPasswordField.text,
            fieldsAndValues: [
                KCSUserAttributeEmail : workerEmailField.text!,
                attributeAccountType: "Worker",
                attributeCompanyName: companyName!,
                attributeDepartmentName: departmentName,
                attributeWorkerName: workerNameField.text!,
                attributeManagerId: managerId,
                attributeLongtitude: companyLongtitude!,
                attributeLatitude: companyLatitude!
            ],
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    self.emailVerificationAlert()
                    user.email = self.workerEmailField.text
                    user.saveWithCompletionBlock({ (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                        if errorOrNil == nil {
                            KCSUser.sendEmailConfirmationForUser(
                                user.email,
                                withCompletionBlock: { (emailSent: Bool, errorOrNil: NSError!) -> Void in
                                    if errorOrNil != nil {
                                    }
                                }
                            )
                        } else {
                        }
                    })
                    KCSUser.activeUser().logout()
                    self.login()
                } else {
                    self.incorrectLoginWithError(errorOrNil)
                }
            }
        )
    }
    
    func login () {
        KCSUser.loginWithUsername(
            username,
            password: passcode,
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                } else {
                }
            }
        )
    }

    func saveWorker() {
        let store = KCSAppdataStore.storeWithOptions([
            KCSStoreKeyCollectionName : "Workers",
            KCSStoreKeyCollectionTemplateClass : Worker.self
            ])
        let worker = Worker()
        worker.name = workerNameField.text
        worker.departmentName = departmentName
        worker.managerId = managerId
        store.saveObject(
            worker,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    NSLog("Save failed, with error: %@", errorOrNil.localizedFailureReason!)
                } else {
                    NSLog("Successfully saved worker (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                }
            },
            withProgressBlock: nil
        )
    }
    
    func emailVerificationAlert() {
        let alert = UIAlertController(title: "New Worker Was Created", message: "Please, make sure that worker will confirm his/her email. ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func incorrectLoginWithError(error:NSError) {
        let alert = UIAlertController(title: "Failed Login", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
  
}
