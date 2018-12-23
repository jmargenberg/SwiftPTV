import UIKit
import Foundation

import CommonCrypto

/**
 Provides ability to simply call version 3 of the PTV API and receive the raw response.
 
 Requires devid and key from PTV.
 
 Strictly conforms to spec at https://timetableapi.ptv.vic.gov.au/swagger/ui/index
 */
class PTV {
    private static let baseURL: URL = URL(string: "http://timetableapi.ptv.vic.gov.au")! // URL of the PTV API
    private static let version: String = "v3" // version of PTV API
    private let devid: String
    private let key: String
    private let urlSession: URLSession
    
    init(devid: String, key: String, urlSession: URLSession = URLSession.shared) {
        self.devid = devid
        self.key = key
        self.urlSession = urlSession
    }
    
    enum CallFailReason {
        case InvalidRequest
        case AccessDenied
        case NoNetworkConnection
        case UnkownError
    }
    
    typealias FailureHandler = (_ callFailReason: CallFailReason, _ message: String?) -> ()
    
    /**
     Calls PTV API at requested api name with provided search string and parameters, calling completion closure on completion with Data object of json response if successful or nil if unsuccessful
     */
    public func call<T: Codable>(apiName: String, searchString: String, params: [String : String]?, decodeTo responseType: T.Type, failure: @escaping FailureHandler, completion: @escaping (_ response: T) -> ()) {
        let url = getCallURL(apiName: apiName, searchString: searchString, params: params)
        
        urlSession.dataTask(with: url) { (data, response, dataTaskError) in
            if let dataTaskError = dataTaskError {
                switch (dataTaskError as! URLError).code {
                case URLError.Code.notConnectedToInternet, URLError.Code.networkConnectionLost, URLError.Code.cannotConnectToHost, URLError.cannotLoadFromNetwork:
                    failure(.NoNetworkConnection, "Unable to connect to network.")
                default:
                    failure(.UnkownError, nil)
                }
                
            } else if let data = data {
                do {
                    completion(try JSONDecoder().decode(responseType, from: data))
                } catch {
                    let errorResponseMessage: String?
                    
                    do {
                        errorResponseMessage = (try JSONDecoder().decode(ErrorResponse.self, from: data)).message
                    } catch {
                        errorResponseMessage = nil
                    }
                    
                    let responseCode = response != nil ? (response! as! HTTPURLResponse).statusCode : nil
                    
                    switch responseCode {
                    case 400:
                        failure(.InvalidRequest, errorResponseMessage)
                    case 403:
                        failure(.AccessDenied, errorResponseMessage)
                    default:
                        failure(.UnkownError, nil)
                    }
                }
            } else {
                failure(.UnkownError, nil)
            }
            
        }.resume()
    }
    
    /**
     Constructs call URL for provided API name with search string and params, returning the result as a URL.
     
     Call URL is structured as 'base URL / version number / API name / query string'
     */
    private func getCallURL(apiName: String, searchString: String, params: [String : String]?) -> URL {
        //build URL with path
        let requestURLPath = PTV.baseURL.appendingPathComponent(PTV.version).appendingPathComponent(apiName).appendingPathComponent(searchString)
        
        var query: [URLQueryItem] = []
        
        if let params = params {
            for (paramName, value) in params {
                let param = URLQueryItem(name: paramName, value: value)
                query.append(param)
            }
        }
        
        query.append(URLQueryItem(name: "devid", value: self.devid))
        
        var requestComponents = URLComponents(string: requestURLPath.absoluteString)
        requestComponents?.queryItems = query
        
        return signCall(callURL: (requestComponents?.url)!)
    }
    
    /**
     Generates HMAC Digests for given PTV API call URL as described in https://static.ptv.vic.gov.au/PTV/PTV%20docs/API/1475462320/PTV-Timetable-API-key-and-signature-document.RTF
     */
    private func signCall(callURL: URL) -> URL {
        let queryString = String(callURL.absoluteString.dropFirst(PTV.baseURL.absoluteString.count)) // remove base URL as it is not part of the signed URL portion
        
        var signature = ""
        signature = queryString.hmac(key: self.key)
        
        let signatureParam = URLQueryItem(name: "signature", value: signature)
        
        var signedCallURLComponents = URLComponents(string: callURL.absoluteString)
        
        var signedParams = signedCallURLComponents?.queryItems
        signedParams?.append(signatureParam)
        signedCallURLComponents?.queryItems = signedParams
        
        return (signedCallURLComponents?.url)!
    }
}

extension String {
    // based on StackOverflow reply by sundance in https://stackoverflow.com/questions/26970807/implementing-hmac-and-sha1-encryption-in-swift
    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, self, self.count, &digest)
        let data = Data(bytes: digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
    
}
