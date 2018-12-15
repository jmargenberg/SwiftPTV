import Foundation

struct Departure: Codable {
    let stop_id: Int
    let route_id: Int
    let run_id: Int
    let direction_id: Int
    let disruption_ids: [Int]?
    let scheduled_departure_utc: String // encoded in ISO-8601 UTC format
    let estimated_departure_utc: String? // encoded in ISO-8601 UTC format
    let at_platform: Bool? 
    let platform_number: String?
    let flags: String?
    
    // NOTE: These were oringinally implemented as lazy vars but were converted to computed properties to allow use when struct is stored as a constant (such as in a sort(where:) completion closure)
    var scheduledDeparture: Date { get { return ISO8601DateFormatter().date(from: self.scheduled_departure_utc)! } }
    var estimatedDeparture: Date? { get { return self.estimated_departure_utc != nil ? ISO8601DateFormatter().date(from: self.estimated_departure_utc!) : nil } }
    
    var bestAvailableDepartureTimeUTCString: String { get { return self.estimated_departure_utc ?? self.scheduled_departure_utc } }
    var bestAvailableDepartureTime: Date { get { return ISO8601DateFormatter().date(from: self.scheduled_departure_utc)! } }
    
    func timeToDeparture(relativeTo time: Date) -> TimeInterval {
        return self.bestAvailableDepartureTime.timeIntervalSince(time)
    }
    
    func timeSinceDeparture(relativeTo time: Date) -> TimeInterval {
        return timeToDeparture(relativeTo: time) * -1
    }
}
