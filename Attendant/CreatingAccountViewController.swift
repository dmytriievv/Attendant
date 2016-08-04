//
//  CreatingAccountViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 4/10/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit
import CoreLocation

class CreatingAccountViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate {
    
    
    
    //MARK: Properties
    
    let attributeCompanyName = "Company name"
    var attributeLongtitude = "Longtitude"
    var attributeLatitude = "Latitude"
    let attributeAccountType = "Account Type"
    let attributePasscode = "Passcode"
    var locationManager = CLLocationManager()
    var companyLongtitude = ""
    var companyLatitude = ""
    
    
    
    //MARK: Outlets
    
    @IBOutlet weak var companyNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    
    
    //MARK: Actions
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func createButton(sender: UIBarButtonItem) {
        createAccount()
    }
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        location()
        companyNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        checkValidData()
    }
    
    
    
    //MARK: Functions
    
    func location () {
        if CLLocationManager.locationServicesEnabled() {
            let manager = CLLocationManager()
            let currentLocation = manager.location
            companyLongtitude = "\(currentLocation!.coordinate.longitude)"
            companyLatitude = "\(currentLocation!.coordinate.latitude)"
        }
    }
    
    func createAccount () {
        
        KCSUser.userWithUsername(
            emailField.text,
            password: passwordField.text,
            fieldsAndValues: [
                KCSUserAttributeEmail : emailField.text!,
                attributeCompanyName : companyNameField.text!,
                attributeAccountType : "Manager",
                attributePasscode: passwordField.text!,
                attributeLongtitude: companyLongtitude,
                attributeLatitude: companyLatitude,
            ],
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    self.emailVerificationAlert()
                    user.email = self.emailField.text
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
                } else {
                    self.incorrectLoginWithError(errorOrNil)
                }
            }
        )
    }

    func emailVerificationAlert() {
        let alert = UIAlertController(title: "Welcome to Attendant!", message: "Please, check your email inbox for the confimation link.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }

    func incorrectLoginWithError(error:NSError) {
        let alert = UIAlertController(title: "Failed Login", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidData ()
    }
    
    func checkValidData() {
        let companyNameText = companyNameField.text ?? ""
        createButton.enabled = !companyNameText.isEmpty
        let emailText = emailField.text ?? ""
        createButton.enabled = !emailText.isEmpty
        let passwordText = passwordField.text ?? ""
        createButton.enabled = !passwordText.isEmpty
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        createButton.enabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
