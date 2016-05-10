//
//  ContactCell.swift
//  Wanna Date
//
//  Created by Mark Torres on 5/9/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
	
	@IBOutlet weak var contactImageView: UIImageView!
	@IBOutlet weak var contactNameLabel: UILabel!
	@IBOutlet weak var contactDistanceLabel: UILabel!
	
	var contactEmail: String!
	
	// MARK: - Default methods
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	// MARK: - Contact actions
	
	@IBAction func tapContact(sender: AnyObject) {
		print("mailto:", contactEmail)
		if let url = NSURL(string: "mailto:\(contactEmail)") {
			UIApplication.sharedApplication().openURL(url)
		}
	}
	
}
