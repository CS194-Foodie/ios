//
//  OnboardingFoodPreferencesViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

/* CLASS: OnboardingFoodPreferencesViewController
 * -----------------------------------------------
 * View controller for letting the user select their favorite cuisines.  Subclasses
 * OnboardingPreferencesListViewController to display a table of many cuisines to choose.
 * When the user changes their cuisine preferences, we store the changes in our userPreferences
 * object.
 *
 * Since this is the first screen in the onboarding flow, there is an optional cancel button
 * that can be displayed in the upper left to modally exit from onboarding.  This is typically
 * invisible during login, but visible when entered from settings.
 * -----------------------------------------------
 */
class OnboardingFoodPreferencesViewController: OnboardingPreferencesListViewController {
    
    // Visible or invisible cancel button and modally dismisses
    @IBOutlet weak var cancelButton: UIButton!
    
    var cancelButtonVisible = true {
        didSet {
            if cancelButton != nil {
                cancelButton.hidden = !cancelButtonVisible
            }
        }
    }
    
    @IBAction func dismiss(sender:UIButton) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cancelButton.hidden = !cancelButtonVisible
        self.preferenceOptions = ["American", "Chinese", "Thai", "Mexican", "Indian", "Mediterranean", "Japanese", "Greek", "Italian", "Vegetarian", "Vegan"]
        self.selectedPreferences = self.userPreferences.foodPreferences
    }
    
    override func userPreferencesDidChange() {
        super.userPreferencesDidChange()
        self.userPreferences.foodPreferences = self.selectedPreferences
    }
}
