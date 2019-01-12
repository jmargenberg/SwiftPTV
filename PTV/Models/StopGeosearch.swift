import Foundation
import CoreLocation

public struct StopGeosearch: Codable {
    public let stop_id: Int
    public let stop_distance: Float? // distance from searched location
    public let stop_name: String
    public let route_type: Int?
    public let stop_latitude: Double
    public let stop_longitude: Double
    
    // computed property used instead of lazy var to allow use when returned as immutable property
    public var location: CLLocationCoordinate2D { get { return CLLocationCoordinate2D(latitude: self.stop_latitude, longitude: self.stop_longitude) } }
}
