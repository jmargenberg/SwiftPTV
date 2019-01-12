import Foundation

public struct StopsByDistanceResponse: Codable {
    let stops: [StopGeosearch]
    let status: Status
}
