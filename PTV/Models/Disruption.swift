import Foundation

public struct Disruption: Codable {
    let disruption_id: Int
    let title: String
    let url: String?
    let description: String
    let published_on: String? // ISO 8601 UTC encoded string
    let last_updated: String? // ISO 8601 UTC encoded string
    let from_date: String? // ISO 8601 UTC encoded string
    let to_date: String? // ISO 8601 UTC encoded string
    let routes: [Route]?
}
