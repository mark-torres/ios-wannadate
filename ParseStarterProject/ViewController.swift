/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		keepSessionOpen = true
    }
	
	override func viewDidAppear(animated: Bool) {
		// check if current user
		if PFUser.currentUser()?.objectId != nil {
			let userInterest = PFUser.currentUser()?["interested_in"] as? String ?? ""
			if userInterest.isEmpty == true {
				performSegueWithIdentifier("loginToProfile", sender: self)
			} else {
				performSegueWithIdentifier("loginToList", sender: self)
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
	
	@IBAction func tapFBLogin(sender: AnyObject) {
		let fbPermissions = ["public_profile", "email"]
		PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermissions) {
			(user: PFUser?, error: NSError?) -> Void in
			if let user = user {
				print("Login successful!")
				// check if user is new
				if user.isNew {
					// welcome new user
				} else {
					// user came back
				}
				self.performSegueWithIdentifier("loginToProfile", sender: self)
			} else {
				print("Something went wrong when trying to login")
			}
		}
	}
	
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
		presentViewController(alert, animated: true, completion: nil)
	}
}
