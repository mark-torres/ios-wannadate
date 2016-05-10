//
//  ProfileViewController.swift
//  Wanna Date
//
//  Created by Mark Torres on 5/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	@IBOutlet weak var pictureImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var interestChoice: UISegmentedControl!
	
	var mainSpinner: UIActivityIndicatorView!
	var userInterest: String!
	var fbData: [String:String]!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		userInterest = ""
		fbData = [String:String]()
		
		// setup main spinner
		mainSpinner = UIActivityIndicatorView( frame: self.view.frame )
		mainSpinner.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
		
		// Load user data from FB
		// User fields https://developers.facebook.com/docs/graph-api/reference/user/
		// User picture https://developers.facebook.com/docs/graph-api/reference/user/picture/
		let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,gender"])
		showMainSpinner()
		fbRequest.startWithCompletionHandler { (connection, result, error) -> Void in
			self.hideMainSpinner()
			if error == nil {
				let userId = result["id"] as? String ?? ""
				let userName = result["name"] as? String ?? ""
				let userEmail = result["email"] as? String ?? ""
				let userGender = result["gender"] as? String ?? ""
				print(userId,userName,userEmail,userGender)
				self.fbData["id"] = userId
				self.fbData["name"] = userName
				self.fbData["email"] = userEmail
				self.fbData["gender"] = userGender
				
				// set preference
				if let interest = PFUser.currentUser()?["interested_in"] as? String {
					switch(interest) {
						case "men":
							self.interestChoice.selectedSegmentIndex = 0
							break
						case "both":
							self.interestChoice.selectedSegmentIndex = 1
							break
						case "women":
							self.interestChoice.selectedSegmentIndex = 2
							break
						default:
							self.interestChoice.selected = false
					}
				} else {
					switch(userGender) {
						case "female":
							self.interestChoice.selectedSegmentIndex = 0
							break
						case "male":
							self.interestChoice.selectedSegmentIndex = 2
							break
						default:
							self.interestChoice.selected = false
					}
				}
				
				self.nameLabel.text = userName
				
				// https://graph.facebook.com/v2.6/{ID}/picture?type=large
				if userId.isEmpty == false {
					if let taskURL = NSURL(string: "https://graph.facebook.com/v2.6/\(userId)/picture?type=large") {
						let webTask = NSURLSession.sharedSession().dataTaskWithURL(taskURL, completionHandler: {
							(data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
							if error != nil {
								print("Error getting profile picture")
							} else {
								if let profilePicture = UIImage(data: data!) {
									dispatch_async(dispatch_get_main_queue(), { () -> Void in
										self.pictureImageView.image = profilePicture
									})
								}
							}
						})
						webTask.resume()
					}
				}
			}
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
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

	// MARK: Actions
	
	@IBAction func tapChangePicture(sender: AnyObject) {
		// show alert with option to choose a picture from library or camera
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		
		let alert = UIAlertController(title: "Select source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
		let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
			imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
			self.presentViewController(imagePicker, animated: true, completion: nil)
		}
		let libraryAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
			imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
			self.presentViewController(imagePicker, animated: true, completion: nil)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
			print("Cancel")
		}
		
		alert.addAction(cameraAction)
		alert.addAction(libraryAction)
		alert.addAction(cancelAction)
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		self.dismissViewControllerAnimated(true, completion: nil)
		
		// Resize image before loading
		// Image resizing: http://nshipster.com/image-resizing/
		// Use UIKit
		// max size = 1024 pix
		let maxSize: CGFloat = 1024.0
		if image.size.width > maxSize || image.size.height > maxSize {
			showMainSpinner()
			
			var ratio: CGFloat = 0.0
			if image.size.width > image.size.height {
				ratio = maxSize / image.size.width
			} else {
				ratio = maxSize / image.size.height
			}
			
			let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(ratio, ratio))
			let hasAlpha = false
			let scale: CGFloat = 1.0 // Use 1
			
			UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
			image.drawInRect(CGRect(origin: CGPointZero, size: size))
			
			let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			hideMainSpinner()
			print(scaledImage.size)
			pictureImageView.image = scaledImage
		} else {
			print(image.size)
			pictureImageView.image = image
		}
	}
	
	@IBAction func tapChangeInterest(sender: AnyObject) {
		if let sender = sender as? UISegmentedControl {
			switch( sender.selectedSegmentIndex ) {
				case 0:
					userInterest = "men"
					break
				case 1:
					userInterest = "both"
					break
				case 2:
					userInterest = "women"
					break
				default:
					userInterest = ""
			}
		}
	}

	@IBAction func switchRememberMe(sender: AnyObject) {
		if let sender = sender as? UISwitch {
			keepSessionOpen = sender.on
		}
	}
	
	@IBAction func tapSave(sender: AnyObject) {
		// validate data size
		let imageData = UIImageJPEGRepresentation(pictureImageView.image!, 0.9)
		let maxSize: Int = 1024 * 1024 * 10
		if imageData?.length > maxSize {
			showAlert("Warning!", alertMessage: "Image data is more than 10 MB")
			return
		}
		let pictureFile = PFFile(name: "picture.jpg", data: imageData!)
		
		// Save all information to Parse
		if PFUser.currentUser()?.objectId != nil {
			let user = PFUser.currentUser()! as PFUser ?? PFUser()
			user.email = fbData["email"]
			user["name"] = fbData["name"]
			user["gender"] = fbData["gender"]
			user["picture"] = pictureFile
			user["interested_in"] = userInterest
			
			showMainSpinner()
			user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
				self.hideMainSpinner()
				if success == true {
					// saved, do something
					self.performSegueWithIdentifier("profileToList", sender: self)
				} else {
					self.showAlert("Error", alertMessage: "Error saving user data to Parse")
				}
			})
		}
	}

	// MARK: Utility fuctions
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
		presentViewController(alert, animated: true, completion: nil)
	}
	
	func showMainSpinner() {
		mainSpinner.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	func hideMainSpinner() {
		mainSpinner.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
}
