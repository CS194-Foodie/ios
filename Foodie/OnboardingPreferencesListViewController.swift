//
//  OnboardingPreferencesListViewController.swift
//  Foodie
//
//  Created by Nick Troccoli on 5/28/16.
//  Copyright © 2016 NJC. All rights reserved.
//
/*  View Controller with a table displaying a list of options (Strings), from which the user
 *  can select as many as they want.
 *  Selected rows are marked by a checkmark.
 *  In order to inherit from this class, you must connect a UITableView from your storyboard
 *  to the preferencesTableView outlet, and configure 1 prototype Basic cell with the identifier
 *  "preferencesCell".
 *
 *  Additionally, you must set the preferenceOptions (an array of Strings representing choices to choose from)
 *  and selectedPreferences (subset of options currently selected).
 *  Whenever the either is updated, the tableview is reloaded.
 *  Override the userPreferencesDidChange method to listen for user selections.
 */


import UIKit

class OnboardingPreferencesListViewController: OnboardingViewController, UITableViewDelegate, UITableViewDataSource {

    // Checkmark table view to store preferences
    @IBOutlet weak var preferencesTableView:UITableView!
    
    var preferenceOptions = [String]() {
        didSet {
            self.preferencesTableView.reloadData()
        }
    }
    
    var selectedPreferences:Set<String> = [] {
        didSet {
            self.preferencesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesTableView.delegate = self
        preferencesTableView.dataSource = self
        preferencesTableView.layer.cornerRadius = 15.0
        preferencesTableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        preferencesTableView.layer.borderWidth = 1.0
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
    
    func userPreferencesDidChange() {}
}
