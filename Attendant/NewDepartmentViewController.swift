//
//  NewDepartmentViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 5/29/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit
import Photos

class NewDepartmentViewController: UIViewController, UITextFieldDelegate {
    
    
    
    //MARK: Properties
    
    var qrcodeImage: CIImage!

    
    
    //MARK: Outlets
    
    @IBOutlet weak var departmentTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var qrImage: UIImageView!
    
    
    
    //MARK: Actions
    
    @IBAction func saveQRCode(sender: UIButton) {
        CustomPhotoAlbum.sharedInstance.saveImage(qrImage.image!, metadata: ["abc": "abc"])
    }
    
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
            switch status{
            case .Authorized:
                dispatch_async(dispatch_get_main_queue(), {
                    print("Authorized")
                })
                break
            case .Denied:
                dispatch_async(dispatch_get_main_queue(), {
                    print("Denied")
                })
                break
            default:
                dispatch_async(dispatch_get_main_queue(), {
                    print("Default")
                })
                break
            }
        })
        departmentTextField.delegate = self
        checkValidData ()
    }

    
    
    //MARK: Functions
    
    func createQR () {
        
        if qrcodeImage == nil {
            if departmentTextField.text == "" {
                return
            }
            let data = departmentTextField.text!.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            qrcodeImage = filter!.outputImage
            departmentTextField.resignFirstResponder()
            displayQRCodeImage()
        }
        else {
            qrImage.image = nil
            qrcodeImage = nil
        }
        departmentTextField.enabled = !departmentTextField.enabled
    }

    func displayQRCodeImage() {
        let scaleX = qrImage.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = qrImage.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        let softwareContext = CIContext(options: [kCIContextUseSoftwareRenderer:true])
        let caging = softwareContext.createCGImage(transformedImage, fromRect: transformedImage.extent)
        
        qrImage.image = UIImage(CGImage: caging)

    }
    
    func save() {
        let store = KCSAppdataStore.storeWithOptions([
            KCSStoreKeyCollectionName : "Departments",
            KCSStoreKeyCollectionTemplateClass : Deparment.self
            ])
        let department = Deparment()
        department.name = departmentTextField.text
        store.saveObject(
            department,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    NSLog("Save failed, with error: %@", errorOrNil.localizedFailureReason!)
                } else {
                    NSLog("Successfully saved department (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                }
            },
            withProgressBlock: nil
        )
    }
    
    
    
    //MARK: TextField Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        createQR ()
        checkValidData ()
    }
    
    func checkValidData() {
        let departmentNameText = departmentTextField.text ?? ""
        saveButton.enabled = !departmentNameText.isEmpty
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {

            self.save()
        }
    }
    
}
