import Foundation

public struct StopOnRoute: Codable {
    let stop_name: String
    let stop_id: Int
    let route_type: Int?
    let stop_latitude: Double?
    let stop_longitude: Double?
}
