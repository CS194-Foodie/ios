//
//  WelcomeViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBAction func getStarted(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate!
        let logInStoryboard = UIStoryboard(name: "Main", bundle: nil)
        appDelegate.window!!.rootViewController = logInStoryboard.instantiateInitialViewController()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
