//
//  WelcomeViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import EventKit

/* CLASS: WelcomeViewController
 * -------------------------------
 * Simple view controller to display an overview of Foodie.  Displays
 * a "Get Started" button that segues the user to the start of the onboarding flow
 * to input their preferences.
 * -------------------------------
 */
class WelcomeViewController: UIViewController {

    @IBAction func getStarted(sender: UIButton) {
        
        // Request calendar access
        if EKEventStore.authorizationStatusForEntityType(.Event) == .NotDetermined {
            
            let store = EKEventStore()
            store.requestAccessToEntityType(.Event, completion: { (granted:Bool, error:NSError?) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.segueToOnboarding()
                }
            })
        } else {
            segueToOnboarding()
        }
    }
    
    func segueToOnboarding() {
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let firstVC = onboardingStoryboard.instantiateViewControllerWithIdentifier("StartScreen") as! OnboardingFoodPreferencesViewController
        firstVC.cancelButtonVisible = false
        self.navigationController?.pushViewController(firstVC, animated: true)
    }
    
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
