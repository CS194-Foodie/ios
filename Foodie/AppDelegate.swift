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
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse using plist file credentials for the appropriate Parse app
        let parseCredentialsPath = NSBundle.mainBundle().pathForResource("ParseCredentials", ofType: "plist")!
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults(["serverName": "Prod"])
        defaults.synchronize()
        let serverName = defaults.stringForKey("serverName")!
        
        let parseCredentialsDict:Dictionary<String, String> = NSDictionary(contentsOfFile: parseCredentialsPath)![serverName]! as! Dictionary<String, String>
        
        let parseConfiguration = ParseClientConfiguration {
            $0.applicationId = parseCredentialsDict["appID"]!
            $0.server = parseCredentialsDict["serverURL"]!
        }
        
        // Set up Parse and Facebook
        Parse.initializeWithConfiguration(parseConfiguration)
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions: launchOptions)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        setUpNotifications(application)
        FoodieLocationManager.sharedInstance.uploadCurrentLocation()
                
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

    
    //MARK: Notifications
    
    /* Set up local and remote notifications, and our RSVP notification category */
    func setUpNotifications(application:UIApplication) {
        
        // Yes action for RSVP Notification
        let yesAction = UIMutableUserNotificationAction()
        yesAction.identifier = "YES_IDENTIFIER"
        yesAction.title = "Yes"
        yesAction.activationMode = .Background
        yesAction.destructive = false
        yesAction.authenticationRequired = false
        
        // No action for RSVP Notification
        let noAction = UIMutableUserNotificationAction()
        noAction.identifier = "NO_IDENTIFIER"
        noAction.title = "No"
        noAction.activationMode = .Background
        noAction.destructive = false
        noAction.authenticationRequired = false
        
        // RSVP Notification Category
        let rsvpCategory = UIMutableUserNotificationCategory()
        rsvpCategory.identifier = "RSVP_CATEGORY"
        rsvpCategory.setActions([yesAction, noAction], forContext: .Default)
        rsvpCategory.setActions([yesAction, noAction], forContext: .Minimal)
        
        let categories: Set<UIUserNotificationCategory> = [rsvpCategory]
        
        // Set up push notifications
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: categories)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PFPush.handlePush(userInfo)
        
        if userInfo["FoodieNotificationType"] as! String == "RSVP" {
            
            // Check if the user is currently busy
            let eventStore = EKEventStore()
            
            
            
            let notif = UILocalNotification()
            notif.alertBody = "Alert body 2"
            notif.alertTitle = "Alert title"
            notif.alertAction = "Alert action"
            application.presentLocalNotificationNow(notif)
        }
        
        completionHandler(.NoData)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        if let id = identifier where id == "YES_IDENTIFIER" {
           let notif = UILocalNotification()
            notif.alertBody = "Alert body"
            notif.alertTitle = "Alert title"
            notif.alertAction = "Alert action"
            application.presentLocalNotificationNow(notif)
        } else if let id = identifier where id == "NO_IDENTIFIER" {
        
        }
        
        completionHandler()
    }
    
    
    //MARK: Other
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation);
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
        FBSDKAppEvents.activateApp()
    }
}

