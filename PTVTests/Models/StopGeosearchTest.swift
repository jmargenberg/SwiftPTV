import XCTest
import CoreLocation

class StopGeosearchTest: XCTestCase {
    func testLocation() {
        let latitude = -37.817600
        let longitude = 144.957505
        let stopGeosearchSubject = StopGeosearch(stop_id: 0, stop_distance: nil, stop_name: "Flinders Street", route_type: 0, stop_latitude: latitude, stop_longitude: longitude)
        
        let location = stopGeosearchSubject.location
        
        XCTAssertEqual(location.latitude, latitude)
        XCTAssertEqual(location.longitude, longitude)
    }
}
