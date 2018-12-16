import XCTest
@testable import SwiftPTV

class SwiftPTVTests: XCTestCase {
    private var urlSessionMock: URLSessionMock!
    private var swiftPTV: SwiftPTV!
    
    private let devid = "1234567"
    private let key = "9c132d31-6a30-4cac-8d8b-8a1970834799" // example API key from PTV documentation

    override func setUp() {
        super.setUp()
        
        urlSessionMock = URLSessionMock()
        swiftPTV = SwiftPTV(devid: devid, key: key, urlSession: urlSessionMock)
    }

    override func tearDown() {
        urlSessionMock = nil
        
        super.tearDown()
    }
}
