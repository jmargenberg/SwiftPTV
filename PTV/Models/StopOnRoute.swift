import Foundation

public struct StopOnRoute: Codable {
    public let stop_name: String
    public let stop_id: Int
    public let route_type: Int?
    public let stop_latitude: Double?
    public let stop_longitude: Double?
}
