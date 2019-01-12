import Foundation

public struct Route: Codable {
    public let route_id: Int
    public let route_type: Int
    public let route_name: String
    public let route_number: String // # presented to public (not used in API)
}
