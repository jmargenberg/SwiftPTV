import Foundation

struct Route: Codable {
    let route_id: Int
    let route_type: Int
    let route_name: String
    let route_number: String // # presented to public (not used in API)
}
