//
//  Product.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/11/2022.
//

import Foundation

struct Product: Identifiable, Equatable, Codable {
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID = UUID()
    var name: String = ""
    var barcode: String = ""
    var nutrition: NutritionInformation? = NutritionInformation()
    var manufacturer: String?
    var brand: String?
    var product_price: [ProductPrice] = []
    var catagory_1: String
    var catagory_2: String
    var catagory_3: String
//    var ingredients: [Ingredient] = []
    //var price: Double = 0
    //var supermarket: Supermarket?
}

struct ProductPrice: Codable {
    var price: Double
    var supermarket: Supermarket
    var date: Date
}
