//
//  connectToADeviceViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-11-20.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit
import Firebase


struct hostDetails {
    let userName: String
    let email: String
}



class connectToADeviceCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class connectToADeviceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var isDone = false
    var hDetails = [hostDetails]()
    let cellSpacingHeight: CGFloat = 5
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.hDetails.count
       }
       
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return cellSpacingHeight
       }
       
       func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
           view.tintColor = .clear
           let header = view as! UITableViewHeaderFooterView
           header.textLabel?.textColor = UIColor.white
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }

    func getHosts(completion: @escaping (_ message: String) -> Void){
        let db = Firestore.firestore()
                     let ref = db.collection("hosts")
                     ref.getDocuments() {
                         (querySnapshot, error) in
                         if let error = error {
                             print("Error getting hosts: \(error)")
                         } else {
                             for document in querySnapshot!.documents {
                                 let username = document.data()["username"] as! String
                                 let email = document.data()["email"] as! String
                                 self.hDetails.append(hostDetails(userName: username, email: email))
                             }
                          completion("success")
                }
        }
    }
    override func viewDidLoad() {
        getHosts(){ (success) in
            if success == "success" {
                self.isDone = true
                self.tableView.reloadData()
            }
        }
    self.tableView.contentSize.height = CGFloat(self.hDetails.count * 66)
    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    self.tableView.rowHeight = 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
               let cell = tableView.dequeueReusableCell(withIdentifier: "hostCell", for:indexPath) as! connectToADeviceCell
               
                if isDone == true {
                    //print(self.hDetails[indexPath.section].userName)
                    cell.userName?.text = hDetails[indexPath.section].userName
                }
               cell.layer.borderColor = UIColor.black.cgColor
               return cell
           }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           myAccount.hostEmail = hDetails[indexPath.row].email
           print("host email is", myAccount.hostEmail)
        print("username is", hDetails[indexPath.row].userName)
           performSegue(withIdentifier: "castingModeSegue", sender: nil)
       }
}

class connectionApprovalViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class castModeViewController: UIViewController {
    
    override func viewDidLoad() {
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

