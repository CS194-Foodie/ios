//
//  GrabABiteViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/17/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse
import ActionSheetPicker_3_0
import MBProgressHUD


class GrabABiteViewController: UIViewController, MealSchedulerViewDelegate {
    
    var userView: UIView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the status of this user (busy, free, etc.) since the screen we
        // display depends on whether they're already roped into an event
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        
        let params = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!]
        PFCloud.callFunctionInBackground("getUserStatus", withParameters: params) { (object:AnyObject?, error:NSError?) in
            
            hud.hide(true)
            
            // If we got a response, show the appropriate view
            if let obj = object {
                let resultsDict = obj as! [String:String]
                self.displayViewForUserStatus(resultsDict)
                
            } else {
                
                // Otherwise, show an error alert
                let alert = UIAlertController(title: "Error", message: "Could not get user status", preferredStyle: .Alert)
                
                if let e = error {
                    alert.message = "Could not get user status - \(e.localizedDescription)"
                }
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /* Display the appropriate view (schedule view, waiting view, restaurant
     * info view, etc.) depending on whether the user is free or already
     * scheduled.
     */
    func displayViewForUserStatus(statusDict:[String:String]) {
        print(statusDict)
        let schedulerView = MealSchedulerView(frame: self.view.frame)
        schedulerView.delegate = self
        self.userView = schedulerView
        self.view.addSubview(self.userView)
    }
    
    /* Called when the scheduler view's # guests button is tapped, meaning the user wants to change it.
     * This method pops up a picker view to let the user select the # of guests (between the given min and max).
     */
    func mealSchedulerView(mealSchedulerView: MealSchedulerView, numGuestsTappedWithCurrentValue currentValue: Int, maxValue: Int, minValue: Int) {

        let rows = Array(minValue...maxValue)
        let picker = ActionSheetStringPicker(title: "How Many Friends?", rows: rows, initialSelection: rows.indexOf(currentValue)!, doneBlock: {
            (_:ActionSheetStringPicker!, _:Int, selectedValue:AnyObject!) in
            
                // Set the number of guests to the new value
                mealSchedulerView.numGuests = selectedValue as! Int
        }, cancelBlock: nil, origin: self.view)
        
        // Make custom-colored picker buttons
        let foodieOrangeColor = UIColor(red: 0.961, green: 0.569, blue: 0.137, alpha: 1.0)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: nil, action: nil)
        cancelButton.tintColor = foodieOrangeColor
        picker.setCancelButton(cancelButton)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: nil, action: nil)
        doneButton.tintColor = foodieOrangeColor
        picker.setDoneButton(doneButton)
        
        picker.showActionSheetPicker()
    }
    
    /* Called when the user taps the "Schedule" button to make an event */
    func mealSchedulerViewScheduleButtonPressed(mealSchedulerView: MealSchedulerView) {
        
        
    }
}
