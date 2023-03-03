//
//  APIService.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import Combine
import UIKit

protocol APIEngine {
    func get<T: Decodable>(type: T.Type, path: String) -> AnyPublisher<T, Error>
    func post<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>
    func post<T: Codable>(return_type: T.Type, image: UIImage, host: String, port: Int, path: String) -> AnyPublisher<T, Error>
    func put<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>
    func putFile<T: Codable>(type: T.Type, path: String, data: Data) -> AnyPublisher<T, Error>
}


class APIService: APIEngine {
    
    var scheme: String
    var host: String
    var port: Int
    var authService: AuthService
    private var jsonDecoder: JSONDecoder
    
    init(
        scheme: String,
        host: String,
        port: Int,
        authService: AuthService
    ) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.authService = authService
        
        self.jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    // Get Decodable Data from designated path
    func get<T: Decodable>(type: T.Type, path: String) -> AnyPublisher<T, Error>{
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.port = self.port
        components.path = path //"/api/xxx/"
        
        guard let url: URL = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token: String = self.authService.token {
            urlRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }
        
        let dataTaskPublisher: AnyPublisher<T, Error> = URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .map { (data: Data, response: URLResponse) -> Data in data }
            .tryCatch { (failure: URLSession.DataTaskPublisher.Failure) -> Just<Data> in
                //Try To Find From Cache
                guard let cacheedResponse: CachedURLResponse = URLCache
                    .shared
                    .cachedResponse(for: urlRequest) else {
                    throw failure
                }
                return Just(cacheedResponse.data)
            }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
        
        return dataTaskPublisher
    }
    
    func post<T: Codable>(return_type: T.Type, image: UIImage, host: String, port: Int, path: String) -> AnyPublisher<T, Error>{
        
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = host
        components.port = port
        components.path = path //"/api/xxx/"
        
        guard let url: URL = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        urlRequest.httpMethod = "POST"
//        urlRequest.addValue("form-data", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 8.0
//        urlRequest.httpBody = image.jpegData(compressionQuality: 1)
        let uuid = UUID().uuidString
        let CRLF = "\r\n"
        let filename = uuid + ".jpg"
        let formName = "file"
        let type = "image/jpeg"     // file type
        let boundary = String(format: "----iOSURLSessionBoundary.%08x%08x", arc4random(), arc4random())
        var body = Data()

        // file data //
        body.append(("--\(boundary)" + CRLF).data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"formName\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append(("Content-Type: \(type)" + CRLF + CRLF).data(using: .utf8)!)
        if let imagedata = image.jpegData(compressionQuality: 1){
            body.append(imagedata as Data)
        }else{
            print("NO JPG DATA")
        }
        body.append(CRLF.data(using: .utf8)!)

        // footer //
        body.append(("--\(boundary)--" + CRLF).data(using: .utf8)!)
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = body
        let dataTaskPublisher: AnyPublisher<T, Error> = URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .map { (data: Data, response: URLResponse) -> Data in data }
            .tryCatch { (failure: URLSession.DataTaskPublisher.Failure) -> Just<Data> in
                //Try To Find From Cache
                guard let cacheedResponse: CachedURLResponse = URLCache
                    .shared
                    .cachedResponse(for: urlRequest) else {
                    throw failure
                }
                return Just(cacheedResponse.data)
            }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
        
        return dataTaskPublisher
        
    }
    
    func post<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>{
        
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.port = self.port
        components.path = path //"/api/xxx/"
        
        guard let url: URL = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token: String = self.authService.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(object)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let dataTaskPublisher: AnyPublisher<T, Error> = URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .map { (data: Data, response: URLResponse) -> Data in data }
            .tryCatch { (failure: URLSession.DataTaskPublisher.Failure) -> Just<Data> in
                //Try To Find From Cache
                guard let cacheedResponse: CachedURLResponse = URLCache
                    .shared
                    .cachedResponse(for: urlRequest) else {
                    throw failure
                }
                return Just(cacheedResponse.data)
            }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
        
        return dataTaskPublisher
        
    }
    
    func put<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>{
        
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.port = self.port
        components.path = path //"/api/xxx/"
        
        guard let url: URL = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token: String = self.authService.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(object)
        } catch let error {
            print(error.localizedDescription)
            
        }
        
        let dataTaskPublisher: AnyPublisher<T, Error> = URLSession
            .shared.dataTaskPublisher(for: urlRequest)
            .map { (data: Data, response: URLResponse) -> Data in data }
            .tryCatch{ (failure: URLSession.DataTaskPublisher.Failure) -> Just<Data> in
                //Try To Find From Cache
                guard let cacheedResponse: CachedURLResponse = URLCache
                    .shared
                    .cachedResponse(for: urlRequest) else {
                    throw failure
                }
                return Just(cacheedResponse.data)
            }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
        
        return dataTaskPublisher
        
    }
    
    func putFile<T: Codable>(type: T.Type, path: String, data: Data) -> AnyPublisher<T, Error>{
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.port = self.port
        components.path = path
        
        guard let url: URL = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token: String = self.authService.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "PUT"
        request.httpBody = data
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Data in data }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()
        
        return dataTaskPublisher
    }
}
