import Foundation

public struct StopsOnRouteResponse: Codable {
    let stops: [StopOnRoute]
    let status: Status
}
