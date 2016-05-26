//
//  LogInViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import ParseUI

class LogInViewController: PFLogInViewController, PFLogInViewControllerDelegate {
    
    var backgroundImage: UIImageView!
    var backgroundImageDarkView: UIView!

    override func viewDidLoad() {

        /* Only show Facebook login, and request standard Facebook info.
         * Note: because of bug in ParseUI's pod (fixed on GitHub but not the pod)
         * we must set the fields BEFORE calling super.viewDidLoad().  Otherwise,
         * the fields' target/actions will not be set up properly (i.e. the Facebook
         * button won't do anything :( ).
         */
        self.fields = [PFLogInFields.Facebook]
        super.viewDidLoad()
        
        self.facebookPermissions = ["public_profile", "user_friends", "email"]
        
        // Janky, but we want to handle our own delegate calls
        self.delegate = self
        
        // Custom background image
        self.backgroundImage = UIImageView(image: UIImage(named: "EatingBackgroundImage"))
        self.backgroundImage.contentMode = .ScaleAspectFill
        self.logInView!.insertSubview(self.backgroundImage, atIndex: 0)
        
        // Filter to make image darker/faded
        self.backgroundImageDarkView = UIView()
        self.backgroundImageDarkView.backgroundColor = UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 32.0/255.0, alpha: 0.28)
        self.logInView!.insertSubview(self.backgroundImageDarkView, atIndex: 1)
        
        // Custom logo
        let logo = UILabel()
        logo.text = "Foodie"
        logo.textColor = UIColor(red: 245.0/255.0, green: 145.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        logo.font = UIFont(name: "Righteous-Regular", size: 82)
        logInView!.logo = logo
    }
    
    // White status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // stretch backgorund image to fill screen
        self.backgroundImage.frame = CGRectMake(0, 0, self.logInView!.frame.width, self.logInView!.frame.height)
        self.backgroundImageDarkView.frame = CGRectMake(0, 0, self.logInView!.frame.width, self.logInView!.frame.height)
        
        // Position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, (190.0 / 667.0) * logInView!.frame.height, logInView!.frame.width, logoFrame.height)
    }
    
    /* Handles login success */
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.performSegueWithIdentifier("welcome", sender: nil)
    }
    
    /* Handles login errors */
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        if let e = error {
            let alert = UIAlertController(title: "Error", message: "Please try again: \(e.localizedDescription)", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
