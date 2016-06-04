//
//  SettingsTableViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

/* CLASS: SettingsTableViewController
 * -----------------------------------
 * View controller for displaying the settings screen.  Consists of a static tableview with
 * the following 2 sections:
 *
 *      Information:
 *              Row 1: user's name
 *              Row 2: app version
 *              Row 3: Segmented control to switch between Prod and Staging
 *              Row 4: Switch to turn on or off calendar check 
 *                      (checking calendar during RSVP process)
 *
 *      Other Settings:
 *              Row 1: Button to change Foodie preferences
 *              Row 2: Button to go to app Settings page (in Settings app)
 *              Row 3: Button to clear NSUserDefaults
 *              Row 4: Button to log out
 *
 * When the user wants to change their Foodie preferences, this view controller modally
 * presents the onboarding flow that they see upon login, but with the initial cancel
 * button visible so they can exit if they want.
 *
 * When the user changes the server we connect to, we display a dialog stating that
 * the user must kill and relaunch the app to change servers.
 * ------------------------------------
 */
class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var serverSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doNotDisturbSwitch: UISwitch!
    @IBOutlet weak var calendarSwitch: UISwitch!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = PFUser.currentUser()?.objectForKey("name") as? String
        
        // Get the current server name
        let serverName = NSUserDefaults.standardUserDefaults().stringForKey(FoodieStringConstants.ParseServerNameKey)!
        if serverName == "Prod" {
            serverSegmentedControl.selectedSegmentIndex = 0
        } else {
            serverSegmentedControl.selectedSegmentIndex = 1
        }
        
        // Display Do Not Disturb status
        doNotDisturbSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(FoodieStringConstants.DoNotDisturbKey)
        
        // Display calendar status
        calendarSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(FoodieStringConstants.CheckCalendarKey)
    }

    /* Detect when either the preferences or logout button is tapped */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                showPreferences()
            case 1:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            case 2:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
                NSUserDefaults.standardUserDefaults().synchronize()
                UIAlertController.displayAlertWithTitle("Success", message: "NSUserDefaults cleared!",
                                                        presentingViewController:self, okHandler:nil)
            case 3:
                logOut()
            default:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                print("Error: unknown index \(indexPath.row)")
            }
        }
        
        //TODO: Add switch for checking calendar access
    }
    
    /* Reenters the onboarding flow letting the user input their Foodie preferences */
    func showPreferences() {
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboardingNavVC = onboardingStoryboard.instantiateInitialViewController()!
        onboardingNavVC.modalTransitionStyle = .CoverVertical
        self.presentViewController(onboardingNavVC, animated: true, completion: nil)
    }

    func logOut() {
        // Show a loading indicator while we log out
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        hud.labelText = "Logging Out..."
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) in
            
            hud.hide(true)
            if let e = error {
                let alert = UIAlertController(title: "Error", message: "Could not log out - \(e.localizedDescription)", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let logInStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
                let logInVC = logInStoryboard.instantiateInitialViewController()!
                logInVC.modalTransitionStyle = .FlipHorizontal
                self.tabBarController?.navigationController?.presentViewController(logInVC, animated: true, completion: nil)
            }
        }
    }
    
    /* Triggered when the user taps/changes the segmented control to switch servers */
    @IBAction func changeServer(sender:UISegmentedControl) {
        let oldServerName = NSUserDefaults.standardUserDefaults().stringForKey(FoodieStringConstants.ParseServerNameKey)!
        let newServerName = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        if oldServerName != newServerName {
            NSUserDefaults.standardUserDefaults().setObject(newServerName, forKey: FoodieStringConstants.ParseServerNameKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            PFUser.logOutInBackgroundWithBlock { (error:NSError?) in
                if let e = error {
                    
                    // Revert to previous server
                    NSUserDefaults.standardUserDefaults().setObject(oldServerName, forKey: FoodieStringConstants.ParseServerNameKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    UIAlertController.displayAlertWithTitle("Error", message: "Could not log out: \(e.localizedDescription)", presentingViewController: self, okHandler: nil)
                } else {
                    UIAlertController.displayAlertWithTitle("Restart Required", message: "Please kill and relaunch the app to switch servers",
                    presentingViewController: self) {
                        self.logOut()
                    }
                }
            }
        }
    }
    
    /* Triggered when user turns Calendar check on or off */
    @IBAction func changeCalendarPreferences(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: FoodieStringConstants.CheckCalendarKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    /* Triggered when the user turns Do Not Disturb on or off */
    @IBAction func changeDoNotDisturb(sender:UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: FoodieStringConstants.DoNotDisturbKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
