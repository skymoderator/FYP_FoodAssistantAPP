//
//  AppState.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import SwiftUI


class AppState {
    
    static let shared: AppState = {
        let object = AppState()
        object.authService.getUserProfile(apiService: object.apiService)
        return object
    }()
    
    
    // An helper class to fetch/store/retrieve data from server
    var apiService: APIEngine
    var authService: AuthService
    
    private init(){
        let host = "20.205.60.6"//"192.168.1.9"//"127.0.0.1"
        self.authService = AuthService(
            scheme: "http",
            host: host,
            port: 8000
        )
        self.apiService = APIService(
            scheme: "http",
            host: host,
            port: 8000,
            authService: self.authService
        )
    }
}
