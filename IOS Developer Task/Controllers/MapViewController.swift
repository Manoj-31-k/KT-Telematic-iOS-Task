import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var playbackButton: UIButton!
    
    var mapView: GMSMapView!
    var location: (address: String, latitude: Double, longitude: Double)?
    var locations: [(address: String, latitude: Double, longitude: Double)] = []
    var email = ""
    
    private var playbackMarker: GMSMarker?
    private var playbackTimer: Timer?
    private var playbackIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = location ?? (address: "", latitude: 37.7749, longitude: -122.4194) // Default to San Francisco if no initial location
        let camera = GMSCameraPosition.camera(withLatitude: initialLocation.latitude, longitude: initialLocation.longitude, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: mapViewContainer.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapViewContainer.addSubview(mapView)
        
        if let location = location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let marker = GMSMarker(position: coordinate)
            marker.title = location.address
            marker.map = mapView
            mapView.animate(toLocation: coordinate)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playbackButtonTapped(_ sender: UIButton) {
        locations = getLocationsForUser(email: email)
        startPlayback()
    }
    
    private func startPlayback() {
        guard !locations.isEmpty else { return }
        
        // Pin all locations
        for location in locations {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let marker = GMSMarker(position: coordinate)
            marker.title = location.address
            marker.map = mapView
        }
        drawPolyline()
        
        // Start playback of locations
        playbackMarker = GMSMarker()
        playbackMarker?.map = mapView
        playbackIndex = 0
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(playbackNextLocation), userInfo: nil, repeats: true)
    }
    
    @objc private func playbackNextLocation() {
        if playbackIndex < locations.count {
            let location = locations[playbackIndex]
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            playbackMarker?.position = coordinate
            mapView.animate(toLocation: coordinate)
            playbackIndex += 1
        } else {
            playbackTimer?.invalidate()
            playbackTimer = nil
        }
    }
    
    private func drawPolyline() {
        guard !locations.isEmpty else { return }
        let path = GMSMutablePath()
        for location in locations {
            path.add(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .blue
        polyline.strokeWidth = 3
        polyline.map = mapView
    }
}
