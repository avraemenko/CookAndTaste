//
//  Networking.swift
//  L3_NetworkingExample
//
//  Created by Ihor Malovanyi on 28.10.2022.
//

import Foundation


/*
let headers = [
    "content-type": "application/x-www-form-urlencoded",
    "X-RapidAPI-Key": "",
    "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
]

let postData = NSMutableData(data: "instructions=Put the garlic in a pan and then add the onion.".data(using: String.Encoding.utf8)!)

let request = NSMutableURLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/analyzeInstructions")! as URL,
                                        cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
request.httpMethod = "POST"
request.allHTTPHeaderFields = headers
request.httpBody = postData as Data

let session = URLSession.shared
let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
    if (error != nil) {
        print(error)
    } else {
        let httpResponse = response as? HTTPURLResponse
        print(httpResponse)
    }
})

dataTask.resume()
*/


protocol NetworkRequestBodyConvertible {
    
    var data: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var parameters: [String : Any]? { get }
    
}

struct SearchForRecipe: NetworkRequestBodyConvertible {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    var data: Data? {
        nil
    }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var parameters: [String : Any]? {
        ["query" : text]
    }
    
}

struct RecipeByID: NetworkRequestBodyConvertible {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    var data: Data? {
        nil
    }
    
    var queryItems: [URLQueryItem]? { nil }
    
    var parameters: [String : Any]? {
        ["id" : text]
    }
    
}
protocol Endpoint {
    
    var pathComponent: String { get }
    
}

enum RecipesEndpoint: String, Endpoint{

    case analyzer = "recipes/analyzeInstructions"
    case complexSearch = "recipes/complexSearch"

    var pathComponent: String {
        rawValue
    }

}

struct RecipeInfoEndpoint : Endpoint {
    
    var pathComponent: String {
        return "recipes/\(parameter)/information"
    }
    
    private var parameter: String
    
    init(with parameter: String) {
        self.parameter = parameter
    }
}

final class Network<T: Endpoint> {
    
    enum Result {
        
        case data(Data?)
        case error(Error)
        
    }
    
    enum NetworkError: Error {
        
        case badHostString
        
    }
    
    enum Method: String {
        
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case put = "PUT"
        case patch = "PATCH"
        
    }
    
    private var host: URL
    private var headers: [String : String]
    private var session = URLSession.shared
    
    init(_ hostString: String, headers: [String : String] = [:]) throws {
        if let url = URL(string: hostString) {
            self.host = url
            self.headers = headers
            
            return
        }
        
        throw NetworkError.badHostString
    }
    
    private func makeRequest(_ method: Method, _ endpoint: T, _ parameters: NetworkRequestBodyConvertible?) -> URLRequest {
        var request = URLRequest(url: host.appending(path: endpoint.pathComponent))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if method == .get {
            request.url?.append(queryItems: parameters?.queryItems ?? [])
        } else if method == .post {
            request.httpBody = parameters?.data
        }
        
        return request
    }
    
    func perform(_ method: Method, _ endpoint: T, _ parameters: NetworkRequestBodyConvertible? = nil, completion: @escaping (Result) -> ()) {
        let request = makeRequest(method, endpoint, parameters)
        
        session.dataTask(with: request) { data, _, error in
            if let error {
                completion(.error(error))
            } else {
                completion(.data(data))
            }
        }.resume()
    }
    
    func perform(_ method: Method, _ endpoint: T, _ parameters: NetworkRequestBodyConvertible? = nil) async throws -> Data {
        let request = makeRequest(method, endpoint, parameters)
        let (data, _) = try await session.data(for: request)
        return data
    }
    
}












