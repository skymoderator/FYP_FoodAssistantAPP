//
//  User.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation

struct User: Codable, Equatable{
    var id: Int?
    var email: String
    var password: String?
    var lastName: String
    var firstName: String
    var dateOfBirth: Date
    var gender: String
    var userAvator: URL?
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: User.CodingKeys.self)
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd"
//            let birthdate = formatter.string(from: date_of_birth)
//        try container.encode(birthdate, forKey: .date_of_birth)
//        try container.encode(email, forKey: .email)
//        try container.encode(password, forKey: .password)
//        try container.encode(last_name, forKey: .last_name)
//        try container.encode(first_name, forKey: .first_name)
//        try container.encode(gender, forKey: .gender)
//
//    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case password = "password"
        case lastName = "last_name"
        case firstName = "first_name"
        case dateOfBirth = "date_of_birth"
        case gender = "gender"
        case userAvator = "user_avator"
    }
}
