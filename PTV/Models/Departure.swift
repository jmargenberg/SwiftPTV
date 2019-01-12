import Foundation

public struct Departure: Codable {
    public let stop_id: Int
    public let route_id: Int
    public let run_id: Int
    public let direction_id: Int
    public let disruption_ids: [Int]?
    public let scheduled_departure_utc: String // encoded in ISO-8601 UTC format
    public let estimated_departure_utc: String? // encoded in ISO-8601 UTC format
    public let at_platform: Bool?
    public let platform_number: String?
    public let flags: String?
    
    // NOTE: These were oringinally implemented as lazy vars but were converted to computed properties to allow use when struct is stored as a constant (such as in a sort(where:) completion closure)
    public var scheduledDeparture: Date { get { return ISO8601DateFormatter().date(from: self.scheduled_departure_utc)! } }
    public var estimatedDeparture: Date? { get { return self.estimated_departure_utc != nil ? ISO8601DateFormatter().date(from: self.estimated_departure_utc!) : nil } }
    
    public var bestAvailableDepartureTimeUTCString: String { get { return self.estimated_departure_utc ?? self.scheduled_departure_utc } }
    public var bestAvailableDepartureTime: Date { get { return ISO8601DateFormatter().date(from: self.scheduled_departure_utc)! } }
    
    public func timeToDeparture(relativeTo time: Date) -> TimeInterval {
        return self.bestAvailableDepartureTime.timeIntervalSince(time)
    }
    
    public func timeSinceDeparture(relativeTo time: Date) -> TimeInterval {
        return timeToDeparture(relativeTo: time) * -1
    }
}
