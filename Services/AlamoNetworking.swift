//
//  AlamoNetworking.swift
//  L3_NetworkingExample
//
//  Created by Ihor Malovanyi on 28.10.2022.
//

import Foundation
import Alamofire

class AlamoNetworking<T: Endpoint> {
    
    enum Result {
        
        case data(Data?)
        case error(Error)
        
    }
    
    private var host: String
    private var headers: [String : String]
    
    init(_ hostString: String, headers: [String : String] = [:]) {
        self.host = hostString
        self.headers = headers
    }
    
    func perform(_ method: HTTPMethod, _ endpoint: T, _ parameters: NetworkRequestBodyConvertible, completion: @escaping (Result) -> ()) {
        
        AF
            .request(host + "/\(endpoint.pathComponent)", method: method, parameters: parameters.parameters, headers: HTTPHeaders(headers))
            .response { response in
                if let error = response.error {
                    completion(.error(error))
                } else {
                    completion(.data(response.data))
                }
            }
    }
    
    func perform(_ method: HTTPMethod, _ endpoint: T, _ parameters: NetworkRequestBodyConvertible) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            perform(method, endpoint, parameters) { result in
                switch result {
                case .data(let data):
                    continuation.resume(returning: data)
                case .error(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
