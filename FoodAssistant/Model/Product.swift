//
//  Product.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/11/2022.
//

import Foundation
import SwiftUI

struct Product: IdentifyEquateCodeHashable {
    
    var id = UUID()
    var name: String = ""
    var barcode: String = ""
    var nutrition: NutritionInformation?
    var manufacturer: String?
    var brand: String?
    var product_price: [ProductPrice] = []
    var category_1: String?
    var category_2: String?
    var category_3: String?
//    var ingredients: [Ingredient] = []
    //var price: Double = 0
    //var supermarket: Supermarket?
}

struct ProductPrice: Hashable, Codable {
    var price: Double
    var supermarket: Supermarket
    var date: Date
}
