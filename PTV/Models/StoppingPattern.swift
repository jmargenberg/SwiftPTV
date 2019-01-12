import Foundation

public struct StoppingPattern: Codable {
    let departures: [Departure]
    let disruptions: [Disruption]
}
