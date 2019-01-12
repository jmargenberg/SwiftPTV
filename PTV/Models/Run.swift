import Foundation

public struct Run: Codable {
    public let run_id: Int
    public let route_id: Int?
    public let route_type: Int?
    public let final_stop_id: Int?
    public let destination_name: String?
}
