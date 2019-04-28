import Foundation

public struct StopDetails: Codable {
    public let station_description: String
    public let stop_amenities: StopAmenityDetails?
    public let stop_accessibility: StopAccessibility?
    public let stop_location: StopLocation?
}
