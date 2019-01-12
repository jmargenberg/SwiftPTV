import Foundation

public struct Run: Codable {
    let run_id: Int
    let route_id: Int?
    let route_type: Int?
    let final_stop_id: Int?
    let destination_name: String?
}
