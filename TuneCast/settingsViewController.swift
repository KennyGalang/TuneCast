//
//  settingsViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-25.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class settingsViewController: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    
    @IBAction func signOutUser(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "backToSignIn", sender: self)
            myAccount.firstName = ""
            myAccount.lastName = ""
            myAccount.UserName = ""
            myAccount.email = ""
            myAccount.password = ""
            myAccount.points = 0
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        profilePhoto.layer.borderWidth = 2.4
        self.userName.text = myAccount.UserName
    }
}
