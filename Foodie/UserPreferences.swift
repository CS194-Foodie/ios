//
//  UserPreferences.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import Foundation
import Parse

class UserPreferences {
    var foodPreferences: [String]?
    var maxBudget: Int?
    var maxTravelDistance: Int?
    var conversationPreferences: [String]?
    
    // Saves all four values to the current user object, and executes the passed-in block upon finishing.
    func saveInBackgroundWithBlock(block:PFBooleanResultBlock) {
        setUserField("foodPreferences", value: foodPreferences, fallback: [])
        setUserField("maxBudget", value: maxBudget, fallback: 0)
        setUserField("maxTravelDistance", value: maxTravelDistance, fallback: 0)
        setUserField("conversationPreferences", value: conversationPreferences, fallback: [])
        PFUser.currentUser()?.saveInBackgroundWithBlock(block)
    }
    
    // Sets the field in the current user object with the given fieldName to the given value if it
    // exists, or the fallback value otherwise.
    func setUserField(fieldName:String, value:AnyObject?, fallback:AnyObject) {
        if let val = value {
            PFUser.currentUser()?.setObject(val, forKey: fieldName)
        } else {
            PFUser.currentUser()?.setObject(fallback, forKey: fieldName)
        }
    }
}