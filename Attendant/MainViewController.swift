//
//  ViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 4/6/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {
    
    
    
    //MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    
    
    //MARK: Actions
    
    @IBAction func signInButton(sender: UIButton) {
        login()
    }
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }


    
    //MARK: Functions
    
    func login () {
        KCSUser.loginWithUsername(
            usernameTextField.text,
            password: passwordTextField.text,
            withCompletionBlock: { (user: KCSUser!, errorOrNil: NSError!, result: KCSUserActionResult) -> Void in
                if errorOrNil == nil {
                    let accountType = KCSUser.activeUser().getValueForAttribute ("Account Type") as! String!
                    if accountType == "Worker" {
                        self.performSegueWithIdentifier("SignInWorker", sender: nil)
                    } else {
                        self.performSegueWithIdentifier("SignInManager", sender: nil)
                    }
                }
                else {
                    self.signInError()
                }
            }
        )
    }
    
    func signInError() {
        let alert = UIAlertController(title: "Failed Login", message: "Username or password you entered is incorrect. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
