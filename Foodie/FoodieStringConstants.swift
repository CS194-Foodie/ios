//
//  FoodieStringConstants.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import Foundation

/* CLASS: FoodieStringConstants
 * ------------------------------
 * Class containing static constants for NSUserDefaults and
 * push notifications keys.
 * ------------------------------
 */
class FoodieStringConstants {
    
    // NSUserDefaults
    static let MostRecentRSVPNoKey = "MostRecentRSVP"
    static let ParseServerNameKey = "ServerName"
    static let DoNotDisturbKey = "DoNotDisturb"
    static let AutoDeclineKey = "AutoDecline"
    
    // Push Notifications
    static let RSVPNotificationCategory = "RSVP_CATEGORY"
    static let RSVPNotificationYesIdentifier = "YES_IDENTIFIER"
    static let RSVPNotificationNoIdentifier = "NO_IDENTIFIER"
    
    // NSNotification
    static let NSNotificationRSVP = "RSVP"
    static let NSNotificationMessage = "Message"
}