//
//  UserModel.swift
//  IOS Developer Task
//
//  Created by Manoj on 02/07/24.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var email = ""
    @objc dynamic var password = ""
    @objc dynamic var isLoggedIn = false
    let locations = List<Location>()
    
    override static func primaryKey() -> String? {
        return "email"
    }
}
