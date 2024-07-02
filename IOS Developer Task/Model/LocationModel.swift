//
//  LocationModel.swift
//  IOS Developer Task
//
//  Created by Manoj on 02/07/24.
//

import Foundation
import RealmSwift

class Location: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var email = ""
    @objc dynamic var address = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
