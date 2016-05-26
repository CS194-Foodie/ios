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

class OnboardingConversationPreferencesViewController: OnboardingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

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
                
                self.delay(1.0) {
                    // Go to the main page
                    let appDelegate = UIApplication.sharedApplication().delegate!
                    let logInStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    appDelegate.window!!.rootViewController = logInStoryboard.instantiateInitialViewController()
                }
            }
        }
    }
    
    // Thanks to http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
    func delay(delay:Double, block:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
}
