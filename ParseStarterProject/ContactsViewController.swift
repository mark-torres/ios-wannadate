//
//  ContactsViewController.swift
//  Wanna Date
//
//  Created by Mark Torres on 5/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class ContactsViewController: UITableViewController {
	
	var userContacts: [PFUser]!
	
	var mainSpinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// setup main spinner
		mainSpinner = UIActivityIndicatorView(frame: self.view.frame)
		mainSpinner.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
		
		// Load accepted users who have accepted the current user
		userContacts = []
		let acceptedByUser = PFUser.currentUser()?["accepted"] as? [String] ?? [String]()
		let userId = PFUser.currentUser()?.objectId ?? ""
		
		if userId.isEmpty == false  && acceptedByUser.count > 0{
			let query = PFUser.query()
			query?.whereKey("accepted", equalTo: userId)
			query?.whereKey("objectId", containedIn: acceptedByUser)
			showMainSpinner()
			query?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
				self.hideMainSpinner()
				if let users = objects as? [PFUser] {
					self.userContacts = users
					self.tableView.reloadData()
				}
			})
			
		}

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userContacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactCell

        // Configure the cell...
		cell.contactNameLabel.text = userContacts[indexPath.row]["name"] as? String ?? "some user \(indexPath.row)"
		
		// calculate distance to contact if location
		var userLocation: PFGeoPoint!
		var contactLocation: PFGeoPoint!
		let contactEmail = userContacts[indexPath.row].email ?? ""
		
		// set contact email
		cell.contactEmail = contactEmail
		
		if let location = PFUser.currentUser()?["location"] as? PFGeoPoint {
			userLocation = location
		}
		if let location = userContacts[indexPath.row]["location"] as? PFGeoPoint {
			contactLocation = location
		}
		if userLocation != nil && contactLocation != nil {
			// distance in KM
			let distance: Double = round(userLocation.distanceInKilometersTo(contactLocation) * 1000)
			cell.contactDistanceLabel.text = "~\(distance/1000) KM away"
		}
		
		// load contact image
		if let contactImageFile = userContacts[indexPath.row]["picture"] as? PFFile {
			contactImageFile.getDataInBackgroundWithBlock({ (data:NSData?, error:NSError?) -> Void in
				if let imageData = data {
					cell.contactImageView.image = UIImage(data: imageData)
				}
			})
		}

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - Utility methods
	
	func showMainSpinner() {
		mainSpinner.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	func hideMainSpinner() {
		mainSpinner.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
		presentViewController(alert, animated: true, completion: nil)
	}
}
