//
//  APIService.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import Combine

protocol APIEngine {
    func get<T: Decodable>(type: T.Type, path: String) -> AnyPublisher<T, Error>
    func post<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>
    func put<T: Codable>(object: T, type: T.Type, path: String) -> AnyPublisher<T, Error>
    func putFile<T: Codable>(type: T.Type, path: String, data: Data) -> AnyPublisher<T, Error>
}


class APIService: APIEngine{

    var scheme: String
    var host: String
    var port: Int
    var authService: AuthService
    private var jsonDecoder: JSONDecoder
    
    init(scheme: String, host: String, port: Int, authService: AuthService){
        self.scheme = scheme
        self.host = host
        self.port = port
        self.authService = authService
        self.jsonDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        self.jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func get<T: Decodable>(type: T.Type, path: String) -> AnyPublisher<T, Error>{
        
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.port = self.port
        components.path = path //"/api/xxx/"

        guard let url = components.url else {
                    preconditionFailure("Invalid URL components: \(components)")
                }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token = self.authService.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let dataTaskPublisher: AnyPublisher<T, Error>  = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .map { (data: Data, response: URLResponse) in
                        
                        return data
                }
                .tryCatch({ failure -> Just<Data> in
                    //Try To Find From Cache
                    guard let cacheedResponse = URLCache.shared.cachedResponse(for: urlRequest) else {
                        throw failure
                    }
                    return Just(cacheedResponse.data)
                   
                })
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

        guard let url = components.url else {
                    preconditionFailure("Invalid URL components: \(components)")
                }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token = self.authService.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(object)
          } catch let error {
            print(error.localizedDescription)
            
          }

        let dataTaskPublisher: AnyPublisher<T, Error>  = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .map { (data: Data, response: URLResponse) in
                        
                        return data
                }
                .tryCatch({ failure -> Just<Data> in
                    //Try To Find From Cache
                    guard let cacheedResponse = URLCache.shared.cachedResponse(for: urlRequest) else {
                        throw failure
                    }
                    return Just(cacheedResponse.data)
                   
                })
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

        guard let url = components.url else {
                    preconditionFailure("Invalid URL components: \(components)")
                }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        URLCache.shared.removeAllCachedResponses()
        if let token = self.authService.token{
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(object)
          } catch let error {
            print(error.localizedDescription)
            
          }

        let dataTaskPublisher: AnyPublisher<T, Error>  = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .map { (data: Data, response: URLResponse) in
                        
                        return data
                }
                .tryCatch({ failure -> Just<Data> in
                    //Try To Find From Cache
                    guard let cacheedResponse = URLCache.shared.cachedResponse(for: urlRequest) else {
                        throw failure
                    }
                    return Just(cacheedResponse.data)
                   
                })
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

        guard let url = components.url else {
                    preconditionFailure("Invalid URL components: \(components)")
                }
        
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        URLCache.shared.removeAllCachedResponses()
        if let token = self.authService.token{
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "PUT"
        request.httpBody = data
        let dataTaskPublisher = URLSession.shared.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) in
                    
                    return data
            }
            .decode(type: T.self, decoder: self.jsonDecoder)
            .eraseToAnyPublisher()

        return dataTaskPublisher
    }
    

}
