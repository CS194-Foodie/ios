//
//  MealWaitingView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import SwiftGifOrigin

/* CLASS: MealWaitingView
 * ---------------------------
 * View that indicates to the user we're in the process of planning
 * an event they're a part of (either creator or RSVPed YES).  Infinitely
 * animates a Pacman gif across the screen using UIView animations.
 * ---------------------------
 */
class MealWaitingView: UIView {
    
    // Constants
    let pacmanDimensions:CGFloat = 100
    let pacmanDistFromBottom:CGFloat = 88
    let pacmanAnimationDuration:Double = 4
    
    // Outlets and views
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var centerView: UIView!
    var pacmanImageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    // Init views and create the Pacman gif in its initial position
    func initSubviews() {
        let nib = UINib(nibName: "MealWaitingView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        // thanks to loading.io for Pacman gif
        pacmanImageView = UIImageView(image: UIImage.gifWithName("pacman"))
        pacmanImageView.frame = CGRectMake(-2 * pacmanDimensions, centerView.frame.height - pacmanDistFromBottom, pacmanDimensions, pacmanDimensions)
        centerView.addSubview(pacmanImageView)
        
        addSubview(contentView)
    }
    
    /* Recursive animation function that animates Pacman horizontally across the screen.
     * Upon completion, calls itself again to repeat the animation.
     */
    func startLoadingAnimation() {
        UIView.animateWithDuration(pacmanAnimationDuration, delay: 0.0, options: .AllowAnimatedContent, animations: {
                
                let oldFrame = self.pacmanImageView.frame
                self.pacmanImageView.frame = CGRectMake(self.centerView.frame.width + oldFrame.width,
                    oldFrame.origin.y, oldFrame.width, oldFrame.height)
                
            }) { (finished:Bool) in
                let oldFrame = self.pacmanImageView.frame
                self.pacmanImageView.frame = CGRectMake(-2 * oldFrame.width, oldFrame.origin.y, oldFrame.width, oldFrame.height)
                self.startLoadingAnimation()
                
        }
    }
}
