import Foundation

struct StopDetails: Codable {
    let station_description: String
    let stop_amenities: StopAmenityDetails
    let stop_accessibility: StopAccessibility
    let stop_location: StopLocation?
}
