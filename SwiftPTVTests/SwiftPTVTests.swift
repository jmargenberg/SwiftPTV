import XCTest
@testable import SwiftPTV

class SwiftPTVTests: XCTestCase {
    private var urlSessionMock: URLSessionMock!

    override func setUp() {
        super.setUp()
        
        urlSessionMock = URLSessionMock()
    }

    override func tearDown() {
        urlSessionMock = nil
        
        super.tearDown()
    }
}
