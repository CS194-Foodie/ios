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
import MapKit
import Contacts

/* CLASS: GrabABiteViewController
 * --------------------------------
 * Main app screen, letting the user either schedule an event for their
 * next meal, or view the status of currently pending (or planned) events.
 * 
 * After appearing, this view controller calls the getUserStatus Cloud Function to determine
 * whether the user is currently roped into any Foodie events (either ones they have planned,
 * or ones they are joining).  What is displayed on this screen depends on the results of this
 * Cloud Function.  If:
 *
 *          user is FREE:
 *              We display a MealSchedulerView, letting the user plan a new meal event.
 *              This view lets the user configure the # guests, and submit the event.
 *              When the user taps the # guests to change it, we pop up a modal ActionSheetPicker.
 *              When the user taps the submit button, we send event info to matchUser.
 *
 *          user is ATTENDING (finalized event):
 *              We display a MealEventView, which displays all information about the
 *              user's upcoming event.
 *          
 *          user is WAITING:
 *              We display a MealWaitingView, letting the user know that the event they are
 *              a part of is still being figured out.
 *
 *          user is INVITED:
 *              We display a MealRSVPView, letting the user respond to their invitation.
 *          
 * --------------------------------
 */
class GrabABiteViewController: UIViewController, MealSchedulerViewDelegate, MealRSVPViewDelegate, MealEventViewDelegate {
    
    var userView: UIView?
    var relevantEvent: PFObject?

    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GrabABiteViewController.handleNotification),
                                                         name: FoodieStringConstants.NSNotificationRSVP, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GrabABiteViewController.handleNotification),
                                                         name: FoodieStringConstants.NSNotificationMessage, object: nil)
        checkUserStatus()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.userView?.removeFromSuperview()
        self.relevantEvent = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        MBProgressHUD.hideAllHUDsForView(self.tabBarController?.view, animated: true)
    }
    
    func handleNotification(notification:NSNotification) {
        self.checkUserStatus()
    }
    
    // Get the status of this user (busy, free, etc.) since the screen we
    // display depends on whether they're already roped into an event
    func checkUserStatus() {
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        
        let params = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!]
        print("Calling getUserStatus with params: \(params)")
        PFCloud.callFunctionInBackground("getUserStatus", withParameters: params).continueWithSuccessBlock { (task:BFTask) -> AnyObject? in
            
            let resultsDict = task.result as! NSDictionary
            let status = resultsDict["status"] as! String
            print("getUserStatus response: \(status)")
            return self.displayViewForUserStatus(resultsDict)
            
        }.continueWithBlock { (task:BFTask) -> AnyObject? in
                
            // On the main thread, stop the loading indicator and display an alert if needed
            dispatch_async(dispatch_get_main_queue()) {
                hud.hide(true)
                    
                if let e = task.error {
                    UIAlertController.displayAlertWithTitle("Error", message: "Could not load view - \(e.localizedDescription)",
                        presentingViewController:self, okHandler: nil)
                    
                // If the user has an event they planned (either they're going to or waiting on),
                // let them cancel it
                } else if let event = self.relevantEvent where (event.objectForKey("creator") as! PFUser).objectId == PFUser.currentUser()!.objectId! {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "I Can't Go", style: .Plain, target: self, action: #selector(GrabABiteViewController.cancelEvent))
                    }
                    
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tabBarController?.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
                
            return nil
        }
    }
    
    /* Cancels the current event, and notifies all users going besides this one */
    func cancelEvent() {
        let params = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!, "eventId": relevantEvent!.objectId!]
        PFCloud.callFunctionInBackground("cancelEvent", withParameters: params) { (_:AnyObject?, error:NSError?) in
            if let e = error {
                dispatch_async(dispatch_get_main_queue()) {
                    UIAlertController.displayAlertWithTitle("Error", message: "Could not cancel event - \(e)", presentingViewController: self, okHandler: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.checkUserStatus()
                }
            }
        }
    }
    
    /* Display the appropriate view (schedule view, waiting view, restaurant
     * info view, etc.) depending on whether the user is free or already
     * scheduled.
     */
    func displayViewForUserStatus(statusDict:NSDictionary) -> BFTask {
        
        var task = BFTask(result: nil)
        let status = statusDict["status"] as! String
        
        if status == "FREE" {
            
            // Load the Parse Config variable for max guests allowed
            task = task.continueWithSuccessBlock { (_:BFTask) -> AnyObject? in
                return PFConfig.getConfigInBackground()
            }.continueWithBlock { (task:BFTask) -> AnyObject? in

                self.relevantEvent = nil

                if let e = task.error {
                    dispatch_async(dispatch_get_main_queue()) {
                        UIAlertController.displayAlertWithTitle("Error",
                            message: "Could not load scheduling view - \(e.localizedDescription)",
                            presentingViewController:self, okHandler: nil)
                    }
                } else {
                    let config = task.result as! PFConfig
                    
                    // Add the scheduler view so the user can schedule events
                    dispatch_async(dispatch_get_main_queue()) {
                        self.userView?.removeFromSuperview()
                        let schedulerView = MealSchedulerView(frame: self.view.frame, maxNumGuests: config["MAX_NUM_GUESTS"] as! Int)
                        schedulerView.delegate = self
                        self.userView = schedulerView
                        self.view.addSubview(self.userView!)
                    }
                }
                
                return nil
            }
            
        } else if status == "WAITING" {
            
            task.continueWithBlock { (_:BFTask) -> AnyObject? in
                
                self.relevantEvent = statusDict["event"] as? PFObject
                
                // Add the waiting view
                dispatch_async(dispatch_get_main_queue()) {
                    self.userView?.removeFromSuperview()
                    let waitingView = MealWaitingView(frame: self.view.frame)
                    self.userView = waitingView
                    self.view.addSubview(self.userView!)
                    (self.userView as! MealWaitingView).startLoadingAnimation()
                }
                
                return nil
            }
        } else if status == "INVITED" {
            
            task.continueWithBlock { (_:BFTask) -> AnyObject? in
                
                self.relevantEvent = statusDict["event"] as? PFObject
                
                // Add the RSVP view
                dispatch_async(dispatch_get_main_queue()) {
                    self.userView?.removeFromSuperview()
                    let rsvpView = MealRSVPView(frame: self.view.frame)
                    rsvpView.delegate = self
                    self.userView = rsvpView
                    self.view.addSubview(self.userView!)
                }
                
                return nil
            }
        } else if status == "ATTENDING" {
            
            task.continueWithBlock { (_:BFTask) -> AnyObject? in
                
                // Fetch all the people going
                self.relevantEvent = statusDict["event"] as? PFObject
                var guests = self.relevantEvent?.objectForKey("goingUsers") as! [PFUser]
                guests.append(self.relevantEvent?.objectForKey("creator") as! PFUser)
                return PFObject.fetchAllIfNeededInBackground(guests)
                
            }.continueWithSuccessBlock { (task:BFTask) -> AnyObject? in
                
                // Extract event info
                let restaurantInfo = self.relevantEvent?.objectForKey("restaurantInfo") as! NSDictionary
                let restaurantName = restaurantInfo["name"] as! String
                let rating = restaurantInfo["rating"] as! Double
                let lat = restaurantInfo["lat"] as! Double
                let lon = restaurantInfo["lon"] as! Double
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                // Remove ourselves from the guest list
                let guests = (task.result as! [PFUser]).filter { $0.objectId != PFUser.currentUser()?.objectId }
                
                // Add the event view
                dispatch_async(dispatch_get_main_queue()) {
                    self.userView?.removeFromSuperview()
                    let eventView = MealEventView(frame: self.view.frame, withRestaurantName: restaurantName,
                        rating: rating, withCoordinates:coordinates, withGuests: guests)
                    eventView.delegate = self
                    self.userView = eventView
                    self.view.addSubview(self.userView!)
                }
                
                return nil
            }
        } else {
            task.continueWithBlock { (_:BFTask) -> AnyObject? in
                return BFTask(error: NSError(domain: "getUserStatusErrorUnknown", code: 3, userInfo: ["status": status]))
            }
        }
        
        return task
    }
    
    
    //MARK: MealEventViewDelegate
    
    func mealEventView(mealEventView: MealEventView, mapTappedForCoordinates coordinates:CLLocationCoordinate2D) {
        let restaurantInfo = self.relevantEvent?.objectForKey("restaurantInfo") as! NSDictionary
        let displayAddress = restaurantInfo["display_address"] as! [String]
        print(displayAddress)
        
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [String(CNPostalAddressStreetKey):displayAddress[0]]))
        item.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
    }
    
    func mealEventViewYelpButtonTapped(mealEventView: MealEventView) {
        let restaurantInfo = self.relevantEvent?.objectForKey("restaurantInfo") as! NSDictionary
        let restaurantId = restaurantInfo["id"] as! String
        
        let yelpInstalled = UIApplication.sharedApplication().canOpenURL(NSURL(string: "yelp:")!)
        if yelpInstalled {
            UIApplication.sharedApplication().openURL(NSURL(string: "yelp:///biz/\(restaurantId)")!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string:"http://yelp.com/biz/\(restaurantId)")!)
        }
    }
    
    
    //MARK: MealRSVPViewDelegate
    
    /* Called when the user RSVPs either Yes or No to the shown event.  This method
     * calls the userRSVP Cloud Function and passes along the response.
     */
    func mealRSVPView(mealRSVPView: MealRSVPView, didRSVPWithResponse canGo: Bool) {
        
        // Store in NSUserDefaults if they declined
        if !canGo {
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: FoodieStringConstants.MostRecentRSVPNoKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Show a loading indicator while we RSVP
        let hud = MBProgressHUD.showHUDAddedTo(self.tabBarController?.view, animated: true)
        hud.labelText = "Sending..."

        let params:[NSObject:AnyObject] = ["sessionToken": (PFUser.currentUser()?.sessionToken!)!,
                                           "canGo": canGo, "eventId": self.relevantEvent!.objectId!]
        print("Calling userRSVP with params: \(params)")
        PFCloud.callFunctionInBackground("userRSVP", withParameters: params).continueWithBlock { (task:BFTask) -> AnyObject? in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let e = task.error {
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
                    hud.labelText = "Sent!"
                    hud.hide(true, afterDelay: 0.5)
                    self.delay(1.0) {
                        self.checkUserStatus()
                    }
                }
            }
            
            return nil
        }
    }
    
    /* Executes the given block after the given delay, in seconds
     * Thanks to http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
     */
    func delay(delay:Double, block:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
    
    
    //MARK: MealSchedulerViewDelegate
    
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
        newEvent.setObject([String](), forKey: "goingUsers")
        newEvent.setObject([String](), forKey: "pendingUsers")
        newEvent.setObject([String](), forKey: "unavailableUsers")
        newEvent.setObject(false, forKey: "isComplete")
        newEvent.setObject(0, forKey: "cuisineIndex")
        newEvent.setObject(PFUser.currentUser()!, forKey: "creator")
        newEvent.setObject([String](), forKey: "cuisines")
        newEvent.setObject([String](), forKey: "invitedUsers")
        
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
                    UIAlertController.displayAlertWithTitle("Error", message: "Could not schedule event - \(error.localizedDescription)",
                        presentingViewController:self, okHandler: nil)
                } else {
                    // Success - display the waiting screen
                    let message =  "We'll let you know when something's scheduled!  EventId: \(newEvent.objectId!)"
                    UIAlertController.displayAlertWithTitle("Success!", message:message, presentingViewController: self) {
                        self.checkUserStatus()
                    }
                }
            }
                
            return nil
        }
        
        
    }
}
