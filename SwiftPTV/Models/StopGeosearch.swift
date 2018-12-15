import Foundation
import CoreLocation

struct StopGeosearch: Codable {
    let stop_id: Int
    let stop_distance: Float? // distance from searched location
    let stop_name: String
    let route_type: Int?
    let stop_latitude: Double
    let stop_longitude: Double
    
    // computed property used instead of lazy var to allow use when returned as immutable property
    var location: CLLocationCoordinate2D { get { return CLLocationCoordinate2D(latitude: self.stop_latitude, longitude: self.stop_longitude) } }
}
