import Foundation

struct StopsOnRouteResponse: Codable {
    let stops: [StopOnRoute]
    let status: Status
}
