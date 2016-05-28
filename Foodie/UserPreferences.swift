//
//  UserPreferences.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/26/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import Foundation
import Parse

/* CLASS: UserPreferences
 * -------------------------
 * A class representing the different preferences a user can enter during onboarding, including:
 *
 *      foodPreferences - a set of strings containing the user's preferred cuisines
 *      maxBudget - the max the user is willing to spend per meal
 *      maxTravelDistance - the max the user is willing to travel (in mi) per meal
 *      conversationPreferences - a set of strings containing the user's favorite conversation topics
 *
 * This object also has a method to upload the current user preferences to the current user's record 
 * (if any) in Parse.
 * -------------------------
 */
class UserPreferences {
    var foodPreferences:Set<String> = []
    var maxBudget = 15
    var maxTravelDistance = 10
    var conversationPreferences:Set<String> = []
    
    // Saves all four values to the current user object, and executes the passed-in block upon finishing.
    func saveInBackgroundWithBlock(block:PFBooleanResultBlock) {
        if let currUser = PFUser.currentUser() {
            currUser.setObject(Array<String>(foodPreferences), forKey: "foodPreferences")
            currUser.setObject(maxBudget, forKey: "maxBudget")
            currUser.setObject(maxTravelDistance, forKey: "maxTravelDistance")
            currUser.setObject(Array<String>(conversationPreferences), forKey: "conversationPreferences")
            currUser.saveInBackgroundWithBlock(block)
        }
    }
}