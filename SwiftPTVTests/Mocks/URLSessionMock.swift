import Foundation

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?,URLResponse?, Error?) -> ()
    
    public var data: Data?
    public var urlResponse: URLResponse?
    public var error: Error?
    public var assertionClosure: ((_ url: URL) -> ())?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        if let _assertClosure = assertionClosure {
            _assertClosure(url)
        }
        
        return URLSessionDataTaskMock {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
}
