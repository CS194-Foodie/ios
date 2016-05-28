//
//  OnboardingMaxTravelDistanceViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

/* CLASS: OnboardingMaxTravelDistanceViewController
 * -------------------------------------------------
 * View controller for letting the user input their max travel distance.
 * We do this by displaying a slider ranging from min to max possible max
 * distance, and updating a label displaying the user's current choice as they
 * change the slider.  Whenever the slider is moved, we update our user preferences
 * object.
 * -------------------------------------------------
 */
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
        self.maxTravelDistance = userPreferences.maxTravelDistance
    }
    
    @IBAction func changeMaxTravelDistance(sender:UISlider) {
        self.maxTravelDistance = Int(sender.value)
    }
}
