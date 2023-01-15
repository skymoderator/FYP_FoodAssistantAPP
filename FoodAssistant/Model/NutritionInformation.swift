//
//  NutritionInformation.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import Foundation

struct NutritionInformation: Identifiable, Equatable, Codable, Hashable {
    
    /*
     All units are per 100ml, not per serving
     */
    
    static func ==(lhs: NutritionInformation, rhs: NutritionInformation) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    
    var energy: Int = 0
    var protein: Double = 0
    var total_fat: Double = 0
    var saturated_fat: Double = 0
    var trans_fat: Double = 0
    var carbohydrates: Double = 0
    var sugars: Double = 0
    var sodium: Double = 0
    
    var cholesterol: Double?
    var vitaminB2: Double?
    var vitaminB3: Double?
    var vitaminB6: Double?
}
