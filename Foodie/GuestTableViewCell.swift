//
//  GuestTableViewCell.swift
//  Foodie
//
//  Created by Nick Troccoli on 6/6/16.
//  Copyright © 2016 NJC. All rights reserved.
//

/* CLASS: GuestTableViewCell
 * ----------------------------
 * A custom UITableViewCell subclass to display info about one event guest.
 * This cell displays their circular Facebook profile picture, and their
 * full name.
 * ----------------------------
 */

import UIKit
import FBSDKLoginKit
import Parse

class GuestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureView: FBSDKProfilePictureView!
    
     /* Sets this cell to display info for the given user. */
    func bindToUser(user:PFUser) {
        profilePictureView.profileID = user.objectForKey("facebookUserID") as! String
        nameLabel.text = user.objectForKey("name") as? String
        profilePictureView.pictureMode = .Square
        profilePictureView.layer.cornerRadius = profilePictureView.frame.size.width / 2.0
        profilePictureView.clipsToBounds = true
        profilePictureView.setNeedsImageUpdate()
    }
}
