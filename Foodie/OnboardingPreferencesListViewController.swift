//
//  OnboardingPreferencesListViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//


import UIKit

/* CLASS: OnboardingPreferencesListViewController
 * ------------------------------------------------
 * Superclass of all onboarding view controllers displaying a list of multi-selectable preferences.
 * Preferences are displayed as a UITableView, from which the user can select multiple cells.
 * Selected rows are marked by a checkmark.
 * 
 * In order to inherit from this class, you must connect a UITableView from your storyboard
 * to the preferencesTableView outlet, and configure 1 prototype Basic cell with the identifier
 * "preferencesCell".
 *
 * Additionally, you must set the preferenceOptions (an array of Strings representing choices to choose from)
 * and selectedPreferences (set of options currently selected).
 * Whenever the either is updated, the tableview is reloaded.
 * Override the userPreferencesDidChange method to listen for user selections.
 * ------------------------------------------------
 */
class OnboardingPreferencesListViewController: OnboardingViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Appearance constants for our tableview
    let cornerRadius:CGFloat = 15.0
    let borderWidth:CGFloat = 1.0
    let borderColor = UIColor.lightGrayColor().CGColor

    // Checkmark table view to store preferences
    @IBOutlet weak var preferencesTableView:UITableView!
    
    // List of all possible options
    var preferenceOptions = [String]() {
        didSet {
            self.preferencesTableView.reloadData()
        }
    }
    
    // Set of selected options
    var selectedPreferences:Set<String> = [] {
        didSet {
            self.preferencesTableView.reloadData()
        }
    }
    
    // Configure the tableview
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesTableView.delegate = self
        preferencesTableView.dataSource = self
        preferencesTableView.layer.cornerRadius = cornerRadius
        preferencesTableView.layer.borderColor = borderColor
        preferencesTableView.layer.borderWidth = borderWidth
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferenceOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("preferencesCell", forIndexPath: indexPath)
        
        let selectedPreference = preferenceOptions[indexPath.row]
        cell.textLabel?.text = selectedPreference
        
        // Checkmark if the user chose this
        if selectedPreferences.contains(selectedPreference) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedPreference = preferenceOptions[indexPath.row]
        
        selectedPreferences.exclusiveOrInPlace([selectedPreference])
        
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = selectedPreferences.contains(selectedPreference) ? .Checkmark : .None
        userPreferencesDidChange()
    }
    
    /* Shell function that can be overridden to be notified when a user's preferences change */
    func userPreferencesDidChange() {}
}
