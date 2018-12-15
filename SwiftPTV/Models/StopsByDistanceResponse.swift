import Foundation

struct StopsByDistanceResponse: Codable {
    let stops: [StopGeosearch]
    let status: Status
}
