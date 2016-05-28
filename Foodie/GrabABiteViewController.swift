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

    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)

        // Get the status of this user (busy, free, etc.) since the screen we
        // display depends on whether they're already roped into an event
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        
        let params = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!]
        PFCloud.callFunctionInBackground("getUserStatus", withParameters: params).continueWithSuccessBlock { (task:BFTask) -> AnyObject? in
            
            let resultsDict = task.result as! [String:String]
            print("getUserStatus response: \(resultsDict)")
            return self.displayViewForUserStatus(resultsDict)
            
        }.continueWithBlock { (task:BFTask) -> AnyObject? in
            
            // On the main thread, stop the loading indicator and display an alert if needed
            dispatch_async(dispatch_get_main_queue()) {
                hud.hide(true)
                
                if let e = task.error {
                    self.displayAlertWithTitle("Error", message: "Could not load view - \(e.localizedDescription)")
                }
            }
            
            return nil
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.userView.removeFromSuperview()
    }
    
    /* Display the appropriate view (schedule view, waiting view, restaurant
     * info view, etc.) depending on whether the user is free or already
     * scheduled.
     */
    func displayViewForUserStatus(statusDict:[String:String]) -> BFTask {
        
        var task = BFTask(result: nil)
        
        if statusDict["status"] == "FREE" {
            
            // Load the Parse Config variable for max guests allowed
            task = task.continueWithSuccessBlock { (task:BFTask) -> AnyObject? in
                return PFConfig.getConfigInBackground()
            }.continueWithBlock { (task:BFTask) -> AnyObject? in
                
                if let e = task.error {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlertWithTitle("Error",
                            message: "Could not load scheduling view - \(e.localizedDescription)")
                    }
                } else {
                    let config = task.result as! PFConfig
                    
                    // Add the scheduler view so the user can schedule events
                    dispatch_async(dispatch_get_main_queue()) {
                        let schedulerView = MealSchedulerView(frame: self.view.frame, maxNumGuests: config["MAX_NUM_GUESTS"] as! Int)
                        schedulerView.delegate = self
                        self.userView = schedulerView
                        self.view.addSubview(self.userView)
                    }
                }
                
                return nil
            }
        } else {
            print("Not free")
        }
        
        return task
    }
    
    /* Displays a UIAlertController with the given title and message, and an OK button. */
    func displayAlertWithTitle(title:String, message:String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /* Called when the scheduler view's # guests button is tapped, meaning the user wants to change it.
     * This method pops up a picker view to let the user select the # of guests (between the given min and max).
     */
    func mealSchedulerView(mealSchedulerView: MealSchedulerView,
                           numGuestsTappedWithCurrentValue currentValue: Int,
                                                           maxValue: Int,
                                                           minValue: Int) {

        let rows = Array(minValue...maxValue)
        let picker = ActionSheetStringPicker(title: "How Many Friends?",
                                             rows: rows,
                                             initialSelection: rows.indexOf(currentValue)!,
                                             doneBlock: { (_:ActionSheetStringPicker!, _:Int, selectedValue:AnyObject!) in
            
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
        
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        
        // Make a new event object for the server to fill in
        let newEvent = PFObject(className: "Event")
        newEvent.saveInBackground().continueWithSuccessBlock { (task:BFTask) -> AnyObject? in
            
            // Call matchUser, passing along our session token, the ID of the event object we just saved,
            // and the number of guests we want to invite
            let guests = mealSchedulerView.numGuests
            let params = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!, "eventId": newEvent.objectId!, "guests": guests]
            
            print("Calling matchUser with params: \(params)")
            return PFCloud.callFunctionInBackground("matchUser", withParameters: params as [NSObject : AnyObject])
            
        }.continueWithBlock { (task:BFTask) -> AnyObject? in
            
            // On the main thread, stop the loading indicator and display an alert with the status
            dispatch_async(dispatch_get_main_queue()) {
                hud.hide(true)
                
                if let error = task.error {
                    self.displayAlertWithTitle("Error", message: "Could not schedule event - \(error.localizedDescription)")
                } else {
                    self.displayAlertWithTitle("Success!", message: "We'll let you know when something's scheduled!  EventId: \(newEvent.objectId!)")
                }
            }
                
            return nil
        }
        
        
    }
}
