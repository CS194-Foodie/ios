//
//  MealRSVPView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit

/* PROTOCOL: MealRSVPViewDelegate
 * --------------------------------
 * Protocol for a MealRSVPView to notify its delegate when a user has responded
 * to the event invitation.  The MealRSVPView passes along the response.
 * --------------------------------
 */
protocol MealRSVPViewDelegate:class {
    func mealRSVPView(mealRSVPView:MealRSVPView, didRSVPWithResponse response:Bool)
}

/* CLASS: MealRSVPView
 * ----------------------
 * View that displays an event invite to the user, and allows them to respond
 * via Yes/No buttons at the bottom.
 * Passes along the response to our delegate.
 * ----------------------
 */
class MealRSVPView: UIView {
    
    // Constants
    let replyButtonCornerRadius:CGFloat = 40
    
    weak var delegate:MealRSVPViewDelegate?
    
    // Outlets / Views
    @IBOutlet var contentView:UIView!
    @IBOutlet weak var yesButtonView: UIView!
    @IBOutlet weak var noButtonView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    // Init views and yes/no buttons
    func initSubviews() {
        let nib = UINib(nibName: "MealRSVPView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        // Round the reply buttons' corners
        yesButtonView.layer.cornerRadius = replyButtonCornerRadius
        yesButtonView.layer.masksToBounds = true
        noButtonView.layer.cornerRadius = replyButtonCornerRadius
        noButtonView.layer.masksToBounds = true
        
        addSubview(contentView)
    }
    
    /* Triggered when either of the RSVP buttons are tapped.  Send a message to
     * our delegate with the RSVP response.
     */
    @IBAction func rsvp(sender:UIButton) {
        if sender.titleForState(.Normal) == "Yes" {
            delegate?.mealRSVPView(self, didRSVPWithResponse: true)
        } else {
            delegate?.mealRSVPView(self, didRSVPWithResponse: false)
        }
    }
}
