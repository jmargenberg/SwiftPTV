import Foundation

public struct DeparturesResponse: Codable {
    let departures: [Departure]
    
    // 'Expanded objects' - these are complete objects appended to the departures response, only objects referenced in the departures list are returned
    let stops: [String: StopGeosearch]? // StopGeosearch objects (not StopDetails!) indexed by their StopID (int formatted as String)
    let routes: [String: Route]? // Route objects indexed by their routeID (int formatted as String)
    let runs: [String: Run]? // Run objects indexed by their runID (int formatted as String)
    let directions: [String: Direction]? // Direction objects indexed by their directoinID (int formatted as String)
    let disruptions: [String: Disruption]? // Disruption objects indexed by their disruptionID (int formatted as String)
    
    let status: Status
}
