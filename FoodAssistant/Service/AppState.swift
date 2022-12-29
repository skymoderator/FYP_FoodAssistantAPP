//
//  AppState.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import SwiftUI


class AppState{

    
    static let shared = {
        let object = AppState()
        object.authService.getUserProfile(apiService: object.apiService)
        return object
    }()
    

    var apiService: APIEngine//APIService
    var authService: AuthService
    
    private init(){
        let host = "20.205.60.6"//"192.168.1.9"//"127.0.0.1"
        
        self.authService = AuthService(scheme: "http", host: host, port: 8000)
        self.apiService = APIService(scheme: "http", host: host, port: 8000, authService: self.authService)
        
        
    }
    
}
