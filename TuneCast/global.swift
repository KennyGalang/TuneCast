//
//  global.swift
//  TuneCast
//
//  Created by CARFAX Ca on 2019-10-25.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import Firebase


struct myAccount{
    static var UserName: String = ""
    static var firstName: String = ""
    static var lastName: String = ""
    static var phoneName: String = ""
    static var email: String = ""
    static var password: String = ""
    static var profilePhotos: [String: Data] = [:]
    static var points: Int = 0
    static var hostEmail: String = ""
    static var playlistID: String = ""
}

