import XCTest
@testable import PTV

struct Status: Codable, Equatable {
    let version: String
    let health: Int
    
    init(version: String, health: Int) {
        self.version = version
        self.health = health
    }
}

struct Route: Codable, Equatable {
    let route_id: Int
    let route_type: Int
    let route_name: String
    let route_number: String
}

struct RouteResponse: Codable, Equatable {
    let route: Route
    let status: Status
}

struct ErrorResponse: Codable, Equatable {
    let message: String
    let status: Status
}

class PTVTests: XCTestCase {
    private var urlSessionMock: URLSessionMock!
    private var swiftPTV: Adapter!
    
    private let devid = "1234567"
    private let key = "9c132d31-6a30-4cac-8d8b-8a1970834799" // example API key from PTV documentation
    
    private let basePathString = "timetableapi.ptv.vic.gov.au"
    private let apiVersion = "v3"
    
    override func setUp() {
        super.setUp()
        
        urlSessionMock = URLSessionMock()
        swiftPTV = Adapter(devid: devid, key: key, urlSession: urlSessionMock)
    }

    override func tearDown() {
        urlSessionMock = nil
        
        super.tearDown()
    }
    
    func testRequestWithSuccessfulResponse() {
        let expectedCallURL =  URL(string: "\(basePathString)/rouets/9?devid=1234567&")!
        let urlResponse = RouteResponse(route: Route(route_id: 9, route_type: 0, route_name: "Lilydale", route_number: ""), status: Status(version: "3.0", health: 1))
        
        urlSessionMock.data = try? JSONEncoder().encode(urlResponse)
        urlSessionMock.urlResponse = HTTPURLResponse(url: expectedCallURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        urlSessionMock.error = nil
        
        urlSessionMock.assertionClosure = {(url) in
            let urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: true)
            
            XCTAssertEqual(urlComponents!.path, "/\(self.apiVersion)/routes/9", "Path correctly built from version, api name and search string")
            
            XCTAssertEqual(urlComponents!.host, self.basePathString, "Host correct")
            
            XCTAssertEqual(urlComponents!.query, "devid=1234567&signature=55bebdc2973825e59557459f0da0e9cd01a2bd54", "Devid included in parameters and siignature correctly calculated")
            
        }
        
        let completionExecuted = self.expectation(description: "Completion handler is executed")
        let failureIsNotExecuted = self.expectation(description: "Failure handler is not executed")
        failureIsNotExecuted.isInverted = true
        
        swiftPTV.call(apiName: "routes", searchString: "9", params: nil, decodeTo: RouteResponse.self, failure: { (_, _) in
            failureIsNotExecuted.fulfill()
        }) {(routeResponse) in
            completionExecuted.fulfill()
            
            XCTAssertEqual(urlResponse, routeResponse)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestWithAccessDeniedResponse() {
        let expectedCallURL =  URL(string: "\(basePathString)/rouets/9?devid=1")!
        let urlResponse = ErrorResponse(message: "Access denied.", status: Status(version: "3.0", health: 1))
        
        urlSessionMock.data = try? JSONEncoder().encode(urlResponse)
        urlSessionMock.urlResponse = HTTPURLResponse(url: expectedCallURL, statusCode: 403, httpVersion: nil, headerFields: nil)
        urlSessionMock.error = nil
        
        let completionIsNotExecuted = self.expectation(description: "Completion handler is not executed")
        completionIsNotExecuted.isInverted = true
        let failureExecuted = self.expectation(description: "Failure handler is executed")
        
        swiftPTV.call(apiName: "routes", searchString: "9", params: nil, decodeTo: RouteResponse.self, failure: {reason, message  in
            failureExecuted.fulfill()
            
            XCTAssertEqual(reason, .AccessDenied)
            XCTAssertEqual(message, "Access denied.")
        }) {(_) in
            completionIsNotExecuted.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestWithInvaldRequestResponse() {
        let expectedCallURL =  URL(string: "\(basePathString)/rouets/nine?devid=1")!
        let urlResponse = ErrorResponse(message: "Route not found", status: Status(version: "3.0", health: 1))
        
        urlSessionMock.data = try? JSONEncoder().encode(urlResponse)
        urlSessionMock.urlResponse = HTTPURLResponse(url: expectedCallURL, statusCode: 400, httpVersion: nil, headerFields: nil)
        urlSessionMock.error = nil
        
        let completionIsNotExecuted = self.expectation(description: "Completion handler is not executed")
        completionIsNotExecuted.isInverted = true
        let failureExecuted = self.expectation(description: "Failure handler is executed")
        
        swiftPTV.call(apiName: "routes", searchString: "9", params: nil, decodeTo: RouteResponse.self, failure: {reason, message  in
            failureExecuted.fulfill()
            
            XCTAssertEqual(reason, .InvalidRequest)
            XCTAssertEqual(message, "Route not found")
        }) {(_) in
            completionIsNotExecuted.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testReuestWithDataTaskError() {
        urlSessionMock.error = URLError(.notConnectedToInternet)
        
        let completionIsNotExecuted = self.expectation(description: "Completion handler is not executed")
        completionIsNotExecuted.isInverted = true
        let failureExecuted = self.expectation(description: "Failure handler is executed")
        
        swiftPTV.call(apiName: "routes", searchString: "9", params: nil, decodeTo: RouteResponse.self, failure: {reason, message  in
            failureExecuted.fulfill()
            
            XCTAssertEqual(reason, .NoNetworkConnection)
            XCTAssertEqual(message, "Unable to connect to network.")
        }) {(_) in
            completionIsNotExecuted.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
