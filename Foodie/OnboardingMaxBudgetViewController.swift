//
//  OnboardingMaxBudgetViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

class OnboardingMaxBudgetViewController: OnboardingViewController {
    
    // Label displaying the dollar amount of the user's max budget, and corresponding stepper
    @IBOutlet weak var maxBudgetLabel:UILabel!
    @IBOutlet weak var maxBudgetStepper:UIStepper!
    
    // When the max is changed, update our label, stepper value, and stored preferences
    var maxBudget:Int! {
        didSet {
            maxBudgetLabel.text = "$\(maxBudget)"
            maxBudgetStepper.value = Double(maxBudget)
            userPreferences.maxBudget = maxBudget
        }
    }

    // If we've been to this screen before (indicated by a non-nil userPreferences value),
    // restore that value.  Otherwise, default to $15
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let max = userPreferences.maxBudget {
            self.maxBudget = max
        } else {
            self.maxBudget = 15
        }
    }
    
    @IBAction func changeMaxBudget(sender:UIStepper) {
        self.maxBudget = Int(sender.value)
    }
}
