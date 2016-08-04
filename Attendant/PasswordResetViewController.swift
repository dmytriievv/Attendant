//
//  PasswordResetViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/25/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    
    
    //MARK: Outlets
    
    @IBOutlet weak var emailField: UITextField!
    
    
    
    //MARK: Actions
    
    @IBAction func resetPasswordButton(sender: UIButton) {
        passwordReset()
    }
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK: Overriding

    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
    }


    
    //MARK: Functions

    func passwordReset () {
    KCSUser.sendPasswordResetForUser(
        emailField.text,
        withCompletionBlock: { (emailSent: Bool, errorOrNil: NSError!) -> Void in
            self.passwordResetCompleted()
        }
        )
    }

    func passwordResetCompleted() {
        let alert = UIAlertController(title: "Password Reset", message: "An email containing information on how to reset your password has been sent to your address.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (alertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion:nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }

    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
