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
        if(emailBox.text! != ""){
            let emailComma = emailBox.text!.replacingOccurrences(of: ".", with: ",")
            db.collection("users").document(emailComma).getDocument{ (document, error) in
                if let document = document, document.exists{
                    let data = document.data()
                    let md5Data = MD5(string: self.passwordBox.text!)
                    let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
                    if data!["password"] as! String == md5Hex {
                        UserDefaults.standard.set(emailComma, forKey: "email")
                        UserDefaults.standard.set(true, forKey: "signedIn")
                        let firstName = data!["firstName"] as! String
                        let lastName = data!["lastName"] as! String
                        let points = data!["points"] as! Int
                        myAccount.UserName = firstName + " " + lastName
                        myAccount.points = points
                    }
                    else {
                        print("Incorrect Password")
                    }
                }
                else {
                    print("Account Doesnt Exist")
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
