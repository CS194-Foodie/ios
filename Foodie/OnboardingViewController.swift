//
//  OnboardingViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // Keep track of the preferences the user has entered so far so that even if they jump between
    // pages, we can remember what they entered
    var userPreferences = UserPreferences()
    
    // Unwind segue for going back to a previous page
    @IBAction func goBack(segue: UIStoryboardSegue) {}
    
    // For both forward and backwards segues, pass our userPreferences to the destination VC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == "Next" || id == "Fade" {
            let nextVC = segue.destinationViewController as! OnboardingViewController
            nextVC.userPreferences = self.userPreferences
        }
    }
}
