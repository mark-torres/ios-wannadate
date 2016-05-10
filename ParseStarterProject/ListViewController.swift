//
//  ListViewController.swift
//  Wanna Date
//
//  Created by Mark Torres on 5/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class ListViewController: UIViewController {
	
	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var infoLabel: UILabel!
	
	var userList: [PFUser]!
	
	var mainSpinner: UIActivityIndicatorView!
	var imageSpinner: UIActivityIndicatorView!
	
	var screenWidth: CGFloat!
	var screenHeight: CGFloat!
	var screenCenter: CGPoint!
	var startPoint: CGPoint!
	
	var userLoaded: Bool!
	
	// MARK: - Default methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		screenWidth = self.view.bounds.width
		screenHeight = self.view.bounds.height
		screenCenter = self.view.center

		mainSpinner = UIActivityIndicatorView(frame: self.view.frame)
		mainSpinner.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
		
		imageSpinner = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: userImageView.bounds.size) )
		imageSpinner.backgroundColor = UIColor(white: 0.5, alpha: 0.8)
		imageSpinner.center = CGPoint(x: userImageView.bounds.width / 2 , y: userImageView.bounds.height / 2)
		imageSpinner.hidesWhenStopped = true
		imageSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		userImageView.addSubview(imageSpinner)
		
		// Load one user
		userLoaded = false
		PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user:PFObject?, error:NSError?) -> Void in
			self.loadUser()
			
		})
		
		// get user location
		PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint:PFGeoPoint?, error:NSError?) -> Void in
			if error == nil {
				PFUser.currentUser()?["location"] = geoPoint
				PFUser.currentUser()?.saveInBackground()
			}
		}

		// Set start point as the center of the image
		startPoint = userImageView.center
		print(startPoint)
		
		let gesture = UIPanGestureRecognizer(target: self, action: Selector("swiped:") )
		userImageView.addGestureRecognizer(gesture)
		userImageView.userInteractionEnabled = true
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "listToLogin" {
			PFUser.logOut()
		}
	}
	
	// MARK: - Utility methods
	
	func loadUser() {
		// find users matching the current user's preferences
		userList = []
		var genderArray: [String] = []
		let userInterest = PFUser.currentUser()?["interested_in"] as? String ?? ""
		let rejectedByUser = PFUser.currentUser()?["rejected"] as? [String] ?? [String]()
		let acceptedByUser = PFUser.currentUser()?["accepted"] as? [String] ?? [String]()
		var viewedByUser = [String]()
		for userId in rejectedByUser {
			if viewedByUser.contains(userId) == false {
				viewedByUser.append(userId)
			}
		}
		for userId in acceptedByUser {
			if viewedByUser.contains(userId) == false {
				viewedByUser.append(userId)
			}
		}
		switch(userInterest) {
		case "men":
			genderArray = ["male"]
			break
		case "women":
			genderArray = ["female"]
			break
		default:
			genderArray = ["male","female"]
		}

		let userQuery = PFUser.query()
		userQuery?.whereKey("gender", containedIn: genderArray)
		// MARK: GeoBox bounds, 0.01 ~= 1.4 KM
		let locationDelta: Double = 0.5
		if let userLocation = PFUser.currentUser()?["location"] as? PFGeoPoint {
			print("User location", userLocation)
			let swCorner = PFGeoPoint(latitude: userLocation.latitude - locationDelta,
				longitude: userLocation.longitude - locationDelta)
			let neCorner = PFGeoPoint(latitude: userLocation.latitude + locationDelta,
				longitude: userLocation.longitude + locationDelta)
			print(swCorner, neCorner)
			userQuery?.whereKey("location", withinGeoBoxFromSouthwest: swCorner, toNortheast: neCorner)
		}
		// exclude users
		if viewedByUser.count > 0 {
			userQuery?.whereKey("objectId", notContainedIn: viewedByUser)
			print(viewedByUser)
		}
		userQuery?.limit = 1
		showMainSpinner()
		userQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
			self.hideMainSpinner()
			if let users = objects as? [PFUser] {
				self.userList = users
				print("Loaded", users.count, "users")
				if users.count > 0 {
					self.infoLabel.text = users[0]["name"] as? String ?? "user"
					if let imageFile = users[0]["picture"] as? PFFile {
						self.imageSpinner.startAnimating()
						imageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
							self.imageSpinner.stopAnimating()
							if error == nil {
								if let data = imageData {
									self.userImageView.image = UIImage(data: data)
									self.userLoaded = true
								}
							}
						})
					}
				} else {
					self.userImageView.image = UIImage(named: "image-square-placeholder.png")
					self.userLoaded = false
				}
			}
		})
	}
	
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
	
	func swiped(gesture: UIPanGestureRecognizer) {
		// check if picture loaded
//		if userLoaded == false {
//			return
//		}
		let translation = gesture.translationInView(self.view)
		let image = gesture.view!
		
		let accept: Bool = translation.x < 0 ? false : true
		let process: Bool = abs(translation.x) > 80 ? true : false
		
		// translate position
		image.center = CGPoint( x: (startPoint.x + translation.x), y: (startPoint.y + translation.y) )
		
		// setup rotation (1 rad = 57.2958 deg)
		var rotation = CGAffineTransformMakeRotation( translation.x / 60 )
		
		// setup scale (Dx ranges 1 - 150, scale ranges from 1.0 to 0.2)
		let scale = 1.0 - (abs(translation.x) * 0.8 / 150.0)
		var scaling = CGAffineTransformScale(rotation, scale, scale)
		
		image.transform = scaling
		
		// restore
		if gesture.state == UIGestureRecognizerState.Ended {
			// Save user sellection to Parse and load a new user
			if process == true && userList.count > 0 {
				if let userId = userList[0].objectId {
					if accept == true {
						PFUser.currentUser()?.addUniqueObject(userId, forKey: "accepted")
					} else {
						PFUser.currentUser()?.addUniqueObject(userId, forKey: "rejected")
					}
					showMainSpinner()
					PFUser.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
						self.hideMainSpinner()
						if success == true {
							self.loadUser()
						}
					})
				}
			} else {
				self.loadUser()
			}
			// restore image
			print(startPoint)
			image.center = startPoint
			rotation = CGAffineTransformMakeRotation(0)
			scaling = CGAffineTransformScale(rotation, 1, 1)
			image.transform = scaling
		}
	}
}
