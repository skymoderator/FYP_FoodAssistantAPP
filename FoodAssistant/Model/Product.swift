//
//  Product.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/11/2022.
//

import Foundation

struct Product: Identifiable, Equatable {
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    var name: String = ""
    var barcode: String = ""
    var price: Double = 0
    var nutrition = NutritionInformation()
    var ingredients: [Ingredient] = []
    var manufacturer: String?
    
}
