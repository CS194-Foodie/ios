//
//  FoodieLocationManager.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//
/* A class to handle Core Location queries for the user's current location, and uploading
 * the location info to Parse.  This class has a singleton instance which you can call
 * uploadCurrentLocation() on to upload the user's current location to Parse.  This
 * will include both the lat/lon (as a GeoPoint in the currentLocation field) and the
 * city/state (as a String in the currentLocationString field).
 */

import Foundation
import CoreLocation
import Parse

class FoodieLocationManager:NSObject, CLLocationManagerDelegate {

    // Singleton
    static let sharedInstance = FoodieLocationManager()
    
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    /* Public method: attempts to upload current location info to Parse.  Only
     * does so if there is a logged-in user, and the user has (or will) approve location
     * access.  May cause an alert to pop up requesting user permission for their location.
     */
    func uploadCurrentLocation() {
        if let _ = PFUser.currentUser() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                manager.requestWhenInUseAuthorization()
            } else if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
                manager.requestLocation()
            }
        }
    }
    
    /* If we've been approved, request our current location */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        uploadLocationToParse(locations.last!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager error: \(error.localizedDescription)")
    }
    
    /* Upload this info to Parse */
    private func uploadLocationToParse(location:CLLocation) {
        if let user = PFUser.currentUser() {
            let point = PFGeoPoint(location: location)
            user.setObject(point, forKey: "userLocation")
            
            // Reverse geocode the location to get the city and state
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:NSError?) in
                if let placemarks = placemarks, placemark = placemarks.first {
                    let city = placemark.locality!
                    let state = placemark.administrativeArea!
                    user.setObject("\(city), \(state)", forKey: "userLocationString")
                }
                
                user.saveInBackground().continueWithBlock { (task:BFTask) -> AnyObject? in
                    if let e = task.error {
                        print("Error: could not upload user location - \(e.localizedDescription)")
                    } else {
                        print("Uploaded user location")
                    }
                    
                    return nil
                }
            }
        }
    }
}
