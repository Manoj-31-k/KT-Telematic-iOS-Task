//
//  Utils.swift
//  IOS Developer Task
//
//  Created by Manoj on 27/06/24.
//

import Foundation
import UIKit
import RealmSwift

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func getLocationsForUser(email: String) -> [(address: String, latitude: Double, longitude: Double)] {
    let realm = try! Realm()
    if let user = realm.object(ofType: User.self, forPrimaryKey: email) {
        var locations = [(address: String, latitude: Double, longitude: Double)]()
        for location in Array(user.locations) {
            locations.append((address: location.address, latitude: location.latitude, longitude: location.longitude))
        }
        return locations
    } else {
        print("User not found")
        return []
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, actionTitle: String = "OK", completion: (()->Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            completion?()
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
