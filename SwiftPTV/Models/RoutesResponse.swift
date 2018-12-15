import Foundation

struct RoutesResponse: Codable {
    let routes: [Route] // NOTE: spec actually states a single route, but actually returns list of routes
    let status: Status?
}
