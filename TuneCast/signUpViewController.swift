//
//  signUpViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-20.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit
import Firebase

import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

func MD5(string: String) -> Data {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)
    
    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData
}

class signUpViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBAction func textInput(_ sender: UITextField) {
           if (firstName.hasText && lastName.hasText) && (email.hasText && password.hasText) {
               createAccountButton.layer.opacity = 1
               createAccountButton.isEnabled = true
           }
           else {
               createAccountButton.layer.opacity = 0.4
               createAccountButton.isEnabled = false
           }
       }
    
    @IBAction func createAccount(_ sender: UIButton) {
        let md5Data = MD5(string:password.text!)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        let emailString = email.text!
        let emailComma = emailString.replacingOccurrences(of: ".", with: ",")
        
        firstName.text = firstName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        lastName.text = lastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
        //setting up user object
        let db = Firestore.firestore()
        db.collection("users").document(emailComma).setData([
            "email": email.text!,
                    "firstName": firstName.text!,
                    "lastName": lastName.text!,
                    "password": md5Hex,
                    "points": 10,
                    
                ])
        myAccount.firstName = firstName.text!
        myAccount.lastName = lastName.text!
        myAccount.UserName = firstName.text! + " " + lastName.text!
        myAccount.email = email.text!
        myAccount.password = md5Hex
        myAccount.points = 10
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
