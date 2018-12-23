import Foundation

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> ()
    
    init(closure: @escaping () -> ()) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}
