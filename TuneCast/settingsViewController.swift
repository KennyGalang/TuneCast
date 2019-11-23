//
//  settingsViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-25.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit

class settingsViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        profilePhoto.layer.borderWidth = 2.4
        self.userName.text = myAccount.UserName
    }
}
