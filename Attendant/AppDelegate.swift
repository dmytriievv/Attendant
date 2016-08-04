//
//  AppDelegate.swift
//  Attendant
//
//  Created by Valerii Dmytriiev on 3/28/16.
//  Copyright © 2016 Valerii Dmytriiev. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        KCSClient.sharedClient().initializeKinveyServiceForAppKey("kid_WyF4jSpxX-", withAppSecret: "9ba0cfed645e4ba2b99c573f1f73ca2d", usingOptions: nil)
        return true
    }

}

