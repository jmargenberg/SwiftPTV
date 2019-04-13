import XCTest
import PTV

class DepartureTest: XCTestCase {
    func testScheduledAndEstimatedDepartureConvertFromUTCCorrectly() {
        let departureTimeString = "2019-04-13T02:13:00Z"
        let departureTimeDate = Date(timeIntervalSince1970: 1555121580)
        
        let departureSubject = Departure(stop_id: 0, route_id: 0, run_id: 0, direction_id: 0, disruption_ids: nil, scheduled_departure_utc: departureTimeString, estimated_departure_utc: departureTimeString, at_platform: false, platform_number: nil, flags: nil)
        
        XCTAssertEqual(departureTimeDate, departureSubject.scheduledDeparture, "Schedule departure date decoded successfully")
        XCTAssertEqual(departureTimeDate, departureSubject.estimatedDeparture, "Estimated departure date decoded successfully")
    }
    
    func testBestAvailableDepartureReturnsScheduledDepartureWhenEstimatedIsNil() {
        let departureSubject = Departure(stop_id: 0, route_id: 0, run_id: 0, direction_id: 0, disruption_ids: nil, scheduled_departure_utc: "2019-04-13T02:13:00Z", estimated_departure_utc: nil, at_platform: false, platform_number: nil, flags: nil)
        
        XCTAssertEqual(departureSubject.scheduled_departure_utc, departureSubject.bestAvailableDepartureTimeUTCString, "The scheduled time is the best available departure time in string format")
        XCTAssertEqual(departureSubject.scheduledDeparture, departureSubject.bestAvailableDepartureTime, "The scheduled time is the best available departure time in date format")
    }
    
    func testBestAvailableDepartureReturnsEstimatedDepartureTimeWhenEstimatedTimeIsGiven() {
        let departureSubject = Departure(stop_id: 0, route_id: 0, run_id: 0, direction_id: 0, disruption_ids: nil, scheduled_departure_utc: "2019-04-13T02:13:00Z", estimated_departure_utc: "2019-04-13T02:18:00Z", at_platform: false, platform_number: nil, flags: nil)
        
        XCTAssertEqual(departureSubject.estimated_departure_utc, departureSubject.bestAvailableDepartureTimeUTCString, "The estimated time is returned the best available departure time in string format")
        XCTAssertEqual(departureSubject.estimatedDeparture, departureSubject.bestAvailableDepartureTime, "The estimated time is returned as the best available departure time in date format")
    }
    
    func testTimeToDeparture() {
        let queryTime = Date(timeIntervalSince1970: 1555121980)
        
        let departureSubject = Departure(stop_id: 0, route_id: 0, run_id: 0, direction_id: 0, disruption_ids: nil, scheduled_departure_utc: "2019-04-13T02:13:00Z", estimated_departure_utc: "2019-04-13T02:18:00Z", at_platform: false, platform_number: nil, flags: nil)
        
        XCTAssertEqual(departureSubject.timeToDeparture(relativeTo: queryTime), departureSubject.bestAvailableDepartureTime.timeIntervalSince(queryTime), "Departure time is relative to best available time")
    }
    
    func testTimeSinceDeparture() {
        let queryTime = Date(timeIntervalSince1970: 1555121180)
        
        let departureSubject = Departure(stop_id: 0, route_id: 0, run_id: 0, direction_id: 0, disruption_ids: nil, scheduled_departure_utc: "2019-04-13T02:13:00Z", estimated_departure_utc: "2019-04-13T02:18:00Z", at_platform: false, platform_number: nil, flags: nil)
        
        XCTAssertEqual(departureSubject.timeToDeparture(relativeTo: queryTime), departureSubject.bestAvailableDepartureTime.timeIntervalSince(queryTime), "Departure time is relative to best available time")
    }
}
