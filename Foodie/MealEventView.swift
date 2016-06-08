//
//  MealEventView.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//

import UIKit
import Parse
import HCSStarRatingView
import FBSDKLoginKit
import MapKit

/* PROTOCOL: MealEventViewDelegate
 * --------------------------------
 * Protocol for a MealEvent view to communicate interactions back to its delegate.
 * Communicates back when the Yelp button it tapped, or if the map is tapped.
 * --------------------------------
 */
protocol MealEventViewDelegate:class {
    func mealEventViewYelpButtonTapped(mealEventView:MealEventView);
    func mealEventView(mealEventView:MealEventView, mapTappedForCoordinates coordinates:CLLocationCoordinate2D);
}

/* CLASS: MealEventView
 * ---------------------
 * View for displaying info about the user's confirmed event.  Displays the name
 * and rating of the restaurant, a link to view the full page in Yelp,
 * a map of where the restaurant is (tappable, takes you to Maps for directions),
 * and a list of people that are going along with the current user.
 * ---------------------
 */
//TODO: Finish
class MealEventView: UIView, UITableViewDataSource, UITableViewDelegate {

    // Outlets + views
    @IBOutlet var contentView:UIView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var ratingsView: HCSStarRatingView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var guestsTableView: UITableView!
    
    // The info for the event we're displaying
    var guestsGoing: [PFUser]!
    var restaurantName: String!
    var rating: Double!
    var coordinates: CLLocationCoordinate2D!
    
    
    weak var delegate:MealEventViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    init(frame: CGRect, withRestaurantName name:String, rating:Double, withCoordinates coordinates:CLLocationCoordinate2D, withGuests guests:[PFUser]) {
        self.guestsGoing = guests
        self.restaurantName = name
        self.rating = rating
        self.coordinates = coordinates
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "MealEventView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        
        // Restaurant info
        restaurantLabel.text = restaurantName
        ratingsView.value = CGFloat(rating)
        
        // Map view
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 10.0
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 500, 500)
        mapView.setRegion(region, animated: true)
        
        addSubview(contentView)
    }
    
    func initTableView() {
        let cellNib = UINib(nibName: "GuestTableViewCell", bundle: nil)
        guestsTableView.registerNib(cellNib, forCellReuseIdentifier: "GuestCell")
        
        if self.contentView.frame.height > 480.0 {
            guestsTableView.rowHeight = 75
        } else {
            guestsTableView.rowHeight = 52
        }
    }
    
    
    @IBAction func moreInfoButtonPressed(sender: UIButton) {
        self.delegate?.mealEventViewYelpButtonTapped(self)
    }
    
    @IBAction func mapTapped(sender: UIButton) {
        self.delegate?.mealEventView(self, mapTappedForCoordinates: self.coordinates)
    }
    

    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guestsGoing.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GuestCell", forIndexPath: indexPath) as! GuestTableViewCell
        cell.bindToUser(guestsGoing[indexPath.row])
        return cell
    }
}
