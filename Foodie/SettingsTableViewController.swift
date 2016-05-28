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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = PFUser.currentUser()?.objectForKey("name") as? String
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
}
