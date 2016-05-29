//
//  MealEventView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse

/* PROTOCOL: MealEventViewDelegate
 * --------------------------------
 * Protocol for a MealEvent view to communicate interactions back to its delegate.
 * Currently empty.
 * --------------------------------
 */
protocol MealEventViewDelegate:class {
    
}

/* CLASS: MealEventView
 * ---------------------
 * View for displaying info about the user's confirmed event.  Currently
 * only displays the eventId of the event.
 * ---------------------
 */
class MealEventView: UIView {

    // Outlets + views
    @IBOutlet var contentView:UIView!
    @IBOutlet weak var eventIdLabel: UILabel!
    
    // The event we're displaying
    var event: PFObject! = nil
    
    weak var delegate:MealEventViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    init(frame: CGRect, event: PFObject) {
        self.event = event
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "MealEventView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        // Display our event's ID
        self.eventIdLabel.text = "EventId = \(self.event.objectId!)"
        
        addSubview(contentView)
    }

}
