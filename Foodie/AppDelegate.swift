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
        
        // Initialize Parse using plist file credentials for the appropriate Parse app
        let parseCredentialsPath = NSBundle.mainBundle().pathForResource("ParseCredentials", ofType: "plist")!
                
        // Initialize NSUserDefaults (stores server name and most recent RSVP decline)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults([FoodieStringConstants.ParseServerNameKey: "Prod",
            FoodieStringConstants.MostRecentRSVPNoKey: NSDate.distantPast(),
            FoodieStringConstants.DoNotDisturbKey: false,
            FoodieStringConstants.CheckCalendarKey: true])
        defaults.synchronize()
        
        let serverName = defaults.stringForKey(FoodieStringConstants.ParseServerNameKey)!
        
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
        yesAction.identifier = FoodieStringConstants.RSVPNotificationYesIdentifier
        yesAction.title = "Yes"
        yesAction.activationMode = .Background
        yesAction.destructive = false
        yesAction.authenticationRequired = false
        
        // No action for RSVP Notification
        let noAction = UIMutableUserNotificationAction()
        noAction.identifier = FoodieStringConstants.RSVPNotificationNoIdentifier
        noAction.title = "No"
        noAction.activationMode = .Background
        noAction.destructive = false
        noAction.authenticationRequired = false
        
        // RSVP Notification Category
        let rsvpCategory = UIMutableUserNotificationCategory()
        rsvpCategory.identifier = FoodieStringConstants.RSVPNotificationCategory
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
            
            // Decline the RSVP automatically
            if userIsBusy() {
                let params:[NSObject:AnyObject] = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!,
                                                   "canGo": false, "eventId": userInfo["eventId"] as! String]
                print("Automatically calling userRSVP with params: \(params)")
                PFCloud.callFunctionInBackground("userRSVP", withParameters: params) { (_:AnyObject?, error:NSError?) in
                    if let e = error {
                        print("Error - could not decline RSVP - \(e.localizedDescription)")
                        completionHandler(.Failed)
                    } else {
                        print("Successfully declined RSVP")
                        completionHandler(.NewData)
                    }
                }
            } else {
                // Post a notification asking the user to RSVP
                let notif = UILocalNotification()
                notif.alertBody = "Do you want to grab a bite to eat?"
                notif.alertTitle = "Foodie Invitation"
                notif.category = FoodieStringConstants.RSVPNotificationCategory
                notif.userInfo = userInfo
                application.presentLocalNotificationNow(notif)
                
                completionHandler(.NewData)
            }

        }
    }
    
    /* Returns whether or not the user is unavailable */
    func userIsBusy() -> Bool {
        let recentlyDeclined = didDeclineRecentRSVP()
        print("Recently declined? \(recentlyDeclined)")
        let busyCalendar = hasCalendarEventNow()
        print("Busy calendar? \(busyCalendar)")
        let doNotDisturb = NSUserDefaults.standardUserDefaults().boolForKey(FoodieStringConstants.DoNotDisturbKey)
        print("Do not disturb? \(doNotDisturb)")
        
        return recentlyDeclined || busyCalendar || doNotDisturb
    }
    
    /* Returns true if the user declined an RSVP within the last hour */
    func didDeclineRecentRSVP() -> Bool {
        let lastDeclineDate = NSUserDefaults.standardUserDefaults().objectForKey(FoodieStringConstants.MostRecentRSVPNoKey) as! NSDate
        return NSDate().timeIntervalSinceDate(lastDeclineDate) / 60.0 < 60.0
    }
    
    /* Returns true is the user has a calendar event right now */
    func hasCalendarEventNow() -> Bool {
        
        // If we don't have calendar access, or if they turned calendar check off, assume they're free
        if EKEventStore.authorizationStatusForEntityType(.Event) != .Authorized ||
            !NSUserDefaults.standardUserDefaults().boolForKey(FoodieStringConstants.CheckCalendarKey) {
            return false
        } else {
            let store = EKEventStore()
            
            // 5 min ago
            let startDate = NSDate(timeInterval: -60.0 * 5, sinceDate: NSDate())
            
            // 1 hour in the future
            let endDate = NSDate(timeInterval: 60.0 * 60, sinceDate: NSDate())
            
            // Return whether there are any current non-all-day events
            let predicate = store.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
            let events = store.eventsMatchingPredicate(predicate)
            let nonAllDayEvents = events.filter { !$0.allDay }
            return nonAllDayEvents.count > 0
        }
    }
    
    /* Triggered when an RSVP response button is tapped on our local RSVP notification.  Call our Parse Cloud
     * RSVP function to pass along the response.
     */
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        // Get the user's response
        var rsvpResponse: Bool?
        if let id = identifier where id == FoodieStringConstants.RSVPNotificationYesIdentifier {
            rsvpResponse = true
        } else if let id = identifier where id == FoodieStringConstants.RSVPNotificationNoIdentifier {
            rsvpResponse = false
            
            // Don't bother ther user again for another hour
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: FoodieStringConstants.MostRecentRSVPNoKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Send to Parse
        if let response = rsvpResponse {
            let params:[NSObject:AnyObject] = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!,
                                               "canGo": response, "eventId": notification.userInfo!["eventId"] as! String]
            print("Calling userRSVP with params: \(params)")
            PFCloud.callFunctionInBackground("userRSVP", withParameters: params) { (_:AnyObject?, error:NSError?) in
                if let e = error {
                    print("Error - could not respond to RSVP - \(e.localizedDescription)")
                } else {
                    print("Successfully RSVPed")
                }
                
                completionHandler()
            }
        } else {
            completionHandler()
        }
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

