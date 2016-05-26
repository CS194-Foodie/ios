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
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let firstVC = onboardingStoryboard.instantiateViewControllerWithIdentifier("StartScreen") as! OnboardingFoodPreferencesViewController
        firstVC.cancelButtonVisible = false
        self.navigationController?.pushViewController(firstVC, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
