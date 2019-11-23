//
//  accountsViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-11-12.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit

class accountsViewController: UIViewController {
    
    var editButtonPressed = false
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var passwordUpdateView: UIView!
    
    @IBAction func editButton(_ sender: UIButton) {
        if editButtonPressed {
            updateButton.isHidden = true
            deleteButton.isHidden = false
            passwordUpdateView.isHidden = false
            editButtonPressed = false
            edit.setTitle("Edit", for: .normal)
            firstName.isUserInteractionEnabled = false
            lastName.isUserInteractionEnabled = false
            emailAddress.isUserInteractionEnabled = false
            firstName.layer.opacity = 0.4
            lastName.layer.opacity = 0.4
            emailAddress.layer.opacity = 0.4
        } else {
            updateButton.isHidden = false
            deleteButton.isHidden = true
            editButtonPressed = true
            passwordUpdateView.isHidden = true
            edit.setTitle("Cancel", for: .normal)
            firstName.isUserInteractionEnabled = true
            lastName.isUserInteractionEnabled = true
            emailAddress.isUserInteractionEnabled = true
            firstName.layer.opacity = 1
            lastName.layer.opacity = 1
            emailAddress.layer.opacity = 1
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        print("backButtonPressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(myAccount.firstName)
        print(myAccount.lastName)
        print(myAccount.email)
        firstName.text = myAccount.firstName
        lastName.text = myAccount.lastName
        emailAddress.text = myAccount.email
    }
}
