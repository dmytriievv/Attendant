//
//  UserViewController.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 4/7/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit
import AVFoundation

class UserAccountViewController: UIViewController, CLLocationManagerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    
    
    //MARK: Properties
    
    var beepSound : AVAudioPlayer?
    let workerName = KCSUser.activeUser().getValueForAttribute("Name") as! String
    let departmentName = KCSUser.activeUser().getValueForAttribute ("Department name") as! String
    let managerId = KCSUser.activeUser().getValueForAttribute("Manager Id") as! String
    var companyLongtitudeString = KCSUser.activeUser().getValueForAttribute("Longtitude") as! String
    var companyLatitudeString = KCSUser.activeUser().getValueForAttribute("Latitude") as! String
    var locationManager = CLLocationManager()
    var companyLocation = CLLocation()
    var distance = CLLocationDistance()
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]

    
    
    //MARK: Outlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
    //MARK: Actions
    
    @IBAction func flashButton(sender: UIButton) {
        flash()
    }
    
    
    
    //MARK: Overriding
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let beepSound = self.setupAudioPlayerWithFile("beep-08b", type:"mp3") {
            self.beepSound = beepSound
        }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let companyLongtitude : CLLocationDegrees = Double (companyLongtitudeString)!
        let companyLatitude : CLLocationDegrees = Double (companyLatitudeString)!
        companyLocation = CLLocation(latitude: companyLatitude, longitude: companyLongtitude)
        location()
        print (distance)
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(flashButton)
            view.bringSubviewToFront(settingsButton)
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
    }
    
    
    
    //MARK: Functions
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    
    func location () {
        if CLLocationManager.locationServicesEnabled() {
            let manager = CLLocationManager()
            let currentLocation = manager.location
            distance  = currentLocation!.distanceFromLocation(companyLocation)
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            messageLabel.text = ""
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarCodes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if distance < 100 {
            if metadataObj.stringValue == departmentName {
                save()
                beepSound?.play()
                messageLabel.text = "Checked In"
                captureSession?.stopRunning()
                }
            }
        }
    }
    
    func flash () {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    func save() {
        let store = KCSAppdataStore.storeWithOptions([
            KCSStoreKeyCollectionName : "Attendance",
            KCSStoreKeyCollectionTemplateClass : Attendance.self
            ])
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let convertedDate = dateFormatter.stringFromDate(currentDate)
        dateFormatter.dateFormat = "HH:mm"
        let convertedTime = dateFormatter.stringFromDate(currentDate)
        let nameWithTime = "\(workerName) at \(convertedTime)"
        let attendance = Attendance()
        attendance.date = convertedDate
        attendance.time = convertedTime
        attendance.name = nameWithTime
        attendance.managerId = managerId
        attendance.departmentName = departmentName
        store.saveObject(
            attendance,
            withCompletionBlock: { (objectsOrNil: [AnyObject]!, errorOrNil: NSError!) -> Void in
                if errorOrNil != nil {
                    NSLog("Save failed, with error: %@", errorOrNil.localizedFailureReason!)
                } else {
                    NSLog("Successfully saved check in (id='%@').", (objectsOrNil[0] as! NSObject).kinveyObjectId())
                }
            },
            withProgressBlock: nil
        )
    }
    
}