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
            self.performSegue(withIdentifier: "goHome", sender: self)
        }
    }

}

