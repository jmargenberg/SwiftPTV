import Foundation

struct StoppingPattern: Codable {
    let departures: [Departure]
    let disruptions: [Disruption]
}
