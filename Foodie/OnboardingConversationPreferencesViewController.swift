//
//  OnboardingConversationPreferencesViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

/* CLASS: OnboardingConversationPreferencesViewController
 * -------------------------------------------------------
 * View controller for letting the user select their favorite conversation topics.  Subclasses
 * OnboardingPreferencesListViewController to display a table of many topics to choose.
 * When the user changes their conversation preferences, we store the changes in our userPreferences
 * object.
 *
 * Since this is the last onboarding screen, this view controller also handles exiting onboarding
 * and transitioning to the main screen.  When the save button in the upper right is tapped,
 * we tell our user preferences object to save itself to Parse, and then segue to the main screen.
 * -----------------------------------------------
 */
class OnboardingConversationPreferencesViewController: OnboardingPreferencesListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.preferenceOptions = ["Sports", "Art", "Music", "Technology", "Shopping", "Nature", "Cooking", "Games", "Fashion", "Writing",
                    "Movies", "Photography", "Politics"]
        self.selectedPreferences = self.userPreferences.conversationPreferences
    }
    
    override func userPreferencesDidChange() {
        super.userPreferencesDidChange()
        self.userPreferences.conversationPreferences = self.selectedPreferences
    }
    
    /* Triggered when the save button is tapped.  Shows a HUD loading indicator,
     * saves the user's inputted preferences to Parse, removes the HUD on completion,
     * and transitions to the next view controller.
     */
    @IBAction func save(sender:UIButton) {
        
        // Show a loading indicator while we save the user's preferences
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Saving..."
        
        self.userPreferences.saveInBackgroundWithBlock { (bool:Bool, error:NSError?) in
            
            if let e = error {
                
                // On error, display an error message
                hud.mode = .Text
                hud.labelText = "Error: \(e.localizedDescription)"
                hud.hide(true, afterDelay: 1.0)
                
            } else {
                
                // On success, show a success message, hide the HUD, and go to the main screen
                hud.mode = .CustomView
                let image = UIImage(named: "Checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
                hud.customView = UIImageView(image: image)
                hud.square = true
                hud.labelText = "Saved"
                hud.hide(true, afterDelay: 1.0)
                
                self.delay(1.2) {
                    if let vc = self.presentingViewController {
                        
                        // Dismiss ourself
                        vc.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        
                        // Go to the main page
                        let logInStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVC = logInStoryboard.instantiateInitialViewController()!
                        mainVC.modalTransitionStyle = .FlipHorizontal
                        self.navigationController?.presentViewController(mainVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    /* Executes the given block after the given delay, in seconds
     * Thanks to http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
     */
    func delay(delay:Double, block:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
}
