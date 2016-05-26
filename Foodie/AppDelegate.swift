//
//  AppDelegate.swift
//  Foodie
//
//  Created by Nick Troccoli on 4/22/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse using plist file credentials for the appropriate Parse app
        let parseCredentialsPath = NSBundle.mainBundle().pathForResource("ParseCredentials", ofType: "plist")!
        let parseCredentialsDict:Dictionary<String, String> = NSDictionary(contentsOfFile: parseCredentialsPath)!["Prod"]! as! Dictionary<String, String>
        
        let parseConfiguration = ParseClientConfiguration {
            $0.applicationId = parseCredentialsDict["appID"]!
            $0.server = parseCredentialsDict["serverURL"]!
        }
        
        // Set up Parse and Facebook
        Parse.initializeWithConfiguration(parseConfiguration)
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions: launchOptions)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
                
        // Display the correct initial screen
        // http://stackoverflow.com/questions/19962276/best-practices-for-storyboard-login-screen-handling-clearing-of-data-upon-logou
        
        if let _ = PFUser.currentUser() {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = mainStoryboard.instantiateInitialViewController()
        } else {
            let logInStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
            let logInNavVC = logInStoryboard.instantiateInitialViewController()
            self.window?.rootViewController = logInNavVC
        }

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation);
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

