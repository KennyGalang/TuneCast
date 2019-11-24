//
//  ViewController.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-09-09.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        checkAuth()
    }
    func checkAuth(){
            if Auth.auth().currentUser != nil {
                print("auth is not nil")
                self.updateMyAccount(uid: Auth.auth().currentUser!.uid){(success) in
                    if success == "success" {
                        self.performSegue(withIdentifier: "goHome", sender: self)
                    } else {
                        print("could not load user data")
                    }
                }
                
            }
        }
        func updateMyAccount(uid:String, completion: @escaping (_ message: String) -> Void){
            let db = Firestore.firestore()
            let userRef = db.collection("users").whereField("uid", isEqualTo: uid)
            userRef.getDocuments() {
                (querySnapshot, error) in
                if let error = error {
                    print("Error getting host documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let email = document.data()["email"] as! String
                        let username = document.data()["username"] as! String
                        myAccount.UserName = username
                        myAccount.email = email
                        completion("success")
                    }
                    
                }
            }
        }
}

