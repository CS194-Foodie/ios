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

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var serverSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = PFUser.currentUser()?.objectForKey("name") as? String
        
        // Get the current server name
        let serverName = NSUserDefaults.standardUserDefaults().stringForKey("serverName")!
        if serverName == "Prod" {
            serverSegmentedControl.selectedSegmentIndex = 0
        } else {
            serverSegmentedControl.selectedSegmentIndex = 1
        }
    }

    /* Detect when either the preferences or logout button is tapped */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                showPreferences()
            case 1:
                logOut()
            default:
                print("Error: unknown index \(indexPath.row)")
            }
        }
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
        let oldServerName = NSUserDefaults.standardUserDefaults().stringForKey("serverName")!
        let newServerName = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        
        if oldServerName != newServerName {
            NSUserDefaults.standardUserDefaults().setObject(newServerName, forKey: "serverName")
            NSUserDefaults.standardUserDefaults().synchronize()
            displayAlertWithTitle("Restart Required", message: "Please kill and relaunch the app to switch servers")
        }
    }
    
    /* Displays a UIAlertController with the given title and message, and an OK button. */
    func displayAlertWithTitle(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
