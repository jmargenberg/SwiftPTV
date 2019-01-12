import Foundation

public struct Disruption: Codable {
    public let disruption_id: Int
    public let title: String
    public let url: String?
    public let description: String
    public let published_on: String? // ISO 8601 UTC encoded string
    public let last_updated: String? // ISO 8601 UTC encoded string
    public let from_date: String? // ISO 8601 UTC encoded string
    public let to_date: String? // ISO 8601 UTC encoded string
    public let routes: [Route]?
}
