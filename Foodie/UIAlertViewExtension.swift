//
//  UIAlertViewExtension.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import Foundation
import UIKit

/* EXTENSION: UIALERTCONTROLLER
 * -----------------------------
 * A new class method that presents a simple title/message/OK alert
 * on screen, presented by the given view controller, and executing the
 * given block when the OK button is pressed.
 * -----------------------------
 */
extension UIAlertController {
    
    /* Displays a UIAlertController with the given title and message, and an OK button.  Accepts
     * a handler to be executed after the OK button is tapped. */
    class func displayAlertWithTitle(title:String, message:String, presentingViewController:UIViewController, okHandler: (() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default) { (_:UIAlertAction) in
            okHandler?()
        }
        alert.addAction(defaultAction)
        
        presentingViewController.presentViewController(alert, animated: true, completion: nil)
    }
}