//
//  OnboardingMaxTravelDistanceViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

class OnboardingMaxTravelDistanceViewController: OnboardingViewController {
    
    @IBOutlet weak var maxTravelDistanceLabel:UILabel!
    @IBOutlet weak var maxTravelDistanceSlider:UISlider!
    
    // When the max is changed, update our label, slider and stored preferences
    var maxTravelDistance:Int! {
        didSet {
            maxTravelDistanceLabel.text = "\(maxTravelDistance) mi"
            maxTravelDistanceSlider.value = Float(maxTravelDistance)
            userPreferences.maxTravelDistance = maxTravelDistance
        }
    }
    
    // If we've been to this screen before (indicated by a non-nil userPreferences value),
    // restore that value.  Otherwise, default to 10mi
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let max = userPreferences.maxTravelDistance {
            self.maxTravelDistance = max
        } else {
            self.maxTravelDistance = 10
        }
    }
    
    @IBAction func changeMaxTravelDistance(sender:UISlider) {
        self.maxTravelDistance = Int(sender.value)
    }
}
