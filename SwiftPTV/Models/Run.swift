import Foundation

struct Run: Codable {
    let run_id: Int
    let route_id: Int?
    let route_type: Int?
    let final_stop_id: Int?
    private let destination_name: String?
    let status: String?
}
