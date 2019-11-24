//
//  signInViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-20.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class signInViewController: UIViewController {
    
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var passwordBox: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBAction func textInput(_ sender: UITextField) {
        if emailBox.hasText && passwordBox.hasText {
            signInButton.layer.opacity = 1
            signInButton.isEnabled = true
        }
        else {
            signInButton.layer.opacity = 0.4
            signInButton.isEnabled = false
        }
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        let db = Firestore.firestore()
        if(emailBox.text! != "" && passwordBox.text! != ""){
            let email = emailBox.text!
            let password = passwordBox.text!
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
                guard let strongSelf = self else { return }
                let getUserRef = db.collection("users").whereField("email", isEqualTo: email)
                getUserRef.getDocuments { (querysnapshot, error) in
                    if error != nil {
                        print("Document Error: ", error!)
                    } else {
                        if let doc = querysnapshot?.documents, !doc.isEmpty {
                            for document in doc {
                                let firstName = document.data()["firstName"] as! String
                                let lastName = document.data()["lastName"] as! String
                                let username = document.data()["username"] as! String
                                let points = document.data()["points"] as! Int
                                myAccount.UserName = username
                                myAccount.points = points
                                myAccount.email = email
                            }
                        }
                        strongSelf.performSegue(withIdentifier: "goToHome", sender: self)
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
            super.viewDidLoad()
            self.emailBox.layer.cornerRadius = 10.0
            self.passwordBox.layer.cornerRadius = 10.0
            self.signInButton.layer.cornerRadius = 10.0
            // Do any additional setup after loading the view.
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
               
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
