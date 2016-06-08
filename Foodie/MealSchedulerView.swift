//
//  GrabABiteView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/27/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

/* PROTOCOL: MealSchedulerViewDelegate
 * ------------------------------------
 * Delegate protocol to be notified of user interaction with this view
 * (including modifying # guests and scheduling event)
 * ------------------------------------
 */
protocol MealSchedulerViewDelegate : class {
    
    /* Supplies the current # guests button value, and the bounds for what the value can be */
    func mealSchedulerView(mealSchedulerView:MealSchedulerView,
                           numGuestsTappedWithCurrentValue currentValue:Int,
                                                           maxValue:Int,
                                                           minValue:Int)
    
    /* Called when the schedule button was pressed, indicating the user wants to schedule an event */
    func mealSchedulerViewScheduleButtonPressed(mealSchedulerView:MealSchedulerView)
}

/* CLASS: MealSchedulerView
 * ----------------------------
 * View that lets the user schedule a new meal with friends.  Displays
 * the name of the next meal coming up (either "lunch" or "dinner"),
 * and allows the user to select how many guests they'd like to invite.
 * Then, they can tap the "Lets Eat!" button to attempt to schedule the event.
 * 
 * This view has a delegate to allow another object to respond to user interactions
 * with this view, including changing the # guests and tapping the schedule button.
 * ----------------------------
 */
class MealSchedulerView: UIView {
    
    /* CONSTANTS */
    var maxNumGuests = 3
    let minNumGuests = 1
    let scheduleButtonCornerRadius:CGFloat = 25
    
    // (24 hour clock)
    let breakfastCutoffHour = 11 // 11AM
    let lunchCutoffHour = 15 // 4PM cutoff

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var numGuestsButton: UIButton!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var letsEatButtonView: UIView!
    
    weak var delegate: MealSchedulerViewDelegate?
    
    // Number of guests invited, in addition to the creator
    var numGuests: Int {
        get {
            return Int(numGuestsButton.titleLabel!.text!)!
        }
        set {
            numGuestsButton.setTitle("\(newValue)", forState: .Normal)
            friendsLabel.text = newValue == 1 ? "friend" : "friends"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    init(frame: CGRect, maxNumGuests:Int) {
        self.maxNumGuests = maxNumGuests
        super.init(frame:frame)
        initSubviews()
    }
    
    /* Initializes views, displays the default # guests, and figures out what meal is next */
    func initSubviews() {
        let nib = UINib(nibName: "MealSchedulerView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        numGuests = maxNumGuests
                
        // Get the hour
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let dateComps = calendar?.components(.Hour, fromDate: NSDate())
        let hour = dateComps?.hour
        
        // Figure out the meal name
        if hour <= breakfastCutoffHour {
            mealLabel.text = "breakfast"
        } else if hour <= lunchCutoffHour {
            mealLabel.text = "lunch"
        } else {
            mealLabel.text = "dinner"
        }
        
        // Round the "Let's Eat" button's corners
        letsEatButtonView.layer.cornerRadius = scheduleButtonCornerRadius
        letsEatButtonView.layer.masksToBounds = true
        
        addSubview(contentView)
    }
    
    /* Triggered when the user taps the num guests button to change the # guests.
     * Triggers a delegate callback to let our delegate react to the button tap.
     */
    @IBAction func numGuestsTapped(sender:UIButton) {
        delegate?.mealSchedulerView(self, numGuestsTappedWithCurrentValue: numGuests,
                                    maxValue: maxNumGuests, minValue: minNumGuests)
    }
    
    /* Triggered when the user taps the "Schedule" button to schedule an event.
     * Triggers a delegate callback to notify our delegate.
     */
    @IBAction func scheduleButtonPressed(sender:UIButton) {
        delegate?.mealSchedulerViewScheduleButtonPressed(self)
    }
}
