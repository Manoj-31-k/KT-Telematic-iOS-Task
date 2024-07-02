//
//  DashboardViewController.swift
//  IOS Developer Task
//
//  Created by Manoj on 29/06/24.
//

import UIKit
import CoreLocation
import RealmSwift

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var mapTableView: UITableView!
    var locationManager = CLLocationManager()
    var locations: [(address: String, latitude: Double, longitude: Double)] = []
    var email = ""
    var saveBool = true
    
    var locationUpdateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    func configuration() {
        locations = getLocationsForUser(email: email)
        mapTableView.register(UINib(nibName: "DashboardMapCell", bundle: nil), forCellReuseIdentifier: "DashboardMapCell")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        startLocationUpdateTimer()
    }
    
    func startLocationUpdateTimer() {
        locationUpdateTimer?.invalidate() // Invalidate existing timer if any
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            self?.saveBool = true
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    
    func saveLocation(location: CLLocation) {
        if saveBool {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let placemark = placemarks?.first, error == nil {
                    let address = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    self.locations.append((address: address, latitude: lat, longitude: lon))
                    self.addLocationToUser(email: self.email, address: address, latitude: lat, longitude: lon)
                    self.mapTableView.reloadData()
                }
            }
            saveBool = false
        }
        
    }
    
    func addLocationToUser(email: String, address: String, latitude: Double, longitude: Double) {
        let realm = try! Realm()
        
        if let user = realm.object(ofType: User.self, forPrimaryKey: email) {
            let location = Location()
            location.email = email
            location.address = address
            location.latitude = latitude
            location.longitude = longitude
            
            try! realm.write {
                user.locations.append(location)
            }
        }
    }
    
    func deleteAllLocationsForUser(email: String) {
        let realm = try! Realm()
        
        if let user = realm.object(ofType: User.self, forPrimaryKey: email) {
            try! realm.write {
                realm.delete(user.locations)
            }
        }
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        deleteAllLocationsForUser(email: email)
        locations.removeAll()
        mapTableView.reloadData()
    }
    @IBAction func logOutBtnAction(_ sender: Any) {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        navigationController?.popViewController(animated: true)
    }
    
}

extension DashboardViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // Authorization request is still pending
            break
        case .restricted, .denied:
            showLocationDisabledAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            // Permissions granted
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Save location data
        saveLocation(location: location)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        // Schedule the next location request
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 20) { // 15 minutes
            self.locationManager.requestLocation()
        }
    }
    
    
    func showLocationDisabledAlert() {
        let alertController = UIAlertController(
            title: "Location Services Disabled",
            message: "Go to Settings and Enable the Permissions",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardMapCell", for: indexPath) as? DashboardMapCell else {
            return UITableViewCell()
        }
        cell.addressLbl.text = locations[indexPath.row].address
        cell.latitudeLbl.text = "\(locations[indexPath.row].latitude) \(locations[indexPath.row].longitude)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            let selectedLocation = locations[indexPath.row]
            mapViewController.location = selectedLocation
            mapViewController.locations = locations
            mapViewController.email = email
            navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
}

