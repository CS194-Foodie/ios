//
//  SettingsViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) in
            if let e = error {
                let alert = UIAlertController(title: "Error", message: "Could not log out - \(e.localizedDescription)", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let appDelegate = UIApplication.sharedApplication().delegate!
                let logInStoryboard = UIStoryboard(name: "LogIn", bundle: nil)
                appDelegate.window!!.rootViewController = logInStoryboard.instantiateInitialViewController()
            }
        }
        
        /*@IBAction func login() {
         PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_friends", "email"]) {
         (user: PFUser?, error: NSError?) -> Void in
         
         if let user = user {
         if user.isNew {
         print("User signed up and logged in through Facebook!")
         } else {
         print("User logged in through Facebook!")
         }
         } else {
         print("Uh oh.  The user cancelled the Facebook login.")
         }
         }
         }*/
    }
}
