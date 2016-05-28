//
//  OnboardingFoodPreferencesViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

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
        self.preferenceOptions = ["American", "Chinese", "Thai", "Mexican", "Indian", "Mediterranean", "Japanese", "Greek", "Italian"]
        if let foodPreferences = self.userPreferences.foodPreferences {
            self.selectedPreferences = Set<String>(foodPreferences)
        }
    }
    
    override func userPreferencesDidChange() {
        super.userPreferencesDidChange()
        self.userPreferences.foodPreferences = Array<String>(self.selectedPreferences)
    }
}
