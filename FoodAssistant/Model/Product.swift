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
    var prices: [ProductPrice] = []
    var category1: String?
    var category2: String?
    var category3: String?
//    var ingredients: [Ingredient] = []
    //var supermarket: Supermarket?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case barcode = "barcode"
        case nutrition = "nutrition"
        case manufacturer = "manufacturer"
        case brand = "brand"
        case prices = "product_price"
        case category1 = "category_1"
        case category2 = "category_2"
        case category3 = "category_3"
    }
}

struct ProductPrice: Hashable, Codable {
    var price: Double
    var supermarket: Supermarket
    var date: Date
}
