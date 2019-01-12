import Foundation

public struct StoppingPattern: Codable {
    public let departures: [Departure]
    public let disruptions: [Disruption]
}
