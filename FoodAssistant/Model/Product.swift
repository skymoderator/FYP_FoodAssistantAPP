//
//  Product.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/11/2022.
//

import Foundation
import SwiftUI

struct Product: IdentifyEquateCodeHashable {
    
    let id = UUID()
    /// Note:
    /// Because in the `InputFoodProductDetailView`, user can modify the product's name
    /// therefore we are declaring it to be `var` instead of `let` to let `name` be modifiable
    var name: String
    let barcode: String
    let nutrition: NutritionInformation?
    let manufacturer: String?
    let brand: String?
    let prices: [ProductPrice]
    let category1: String?
    let category2: String?
    let category3: String?
//    var ingredients: [Ingredient] = []
    //var supermarket: Supermarket?
    
    init(
        name: String = "",
        barcode: String = "",
        nutrition: NutritionInformation? = nil,
        manufacturer: String? = nil,
        brand: String? = nil,
        prices: [ProductPrice] = [],
        category1: String? = nil,
        category2: String? = nil,
        category3: String? = nil
    ) {
        self.name = name
        self.barcode = barcode
        self.nutrition = nutrition
        self.manufacturer = manufacturer
        self.brand = brand
        self.prices = prices
        self.category1 = category1
        self.category2 = category2
        self.category3 = category3
    }
    
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
    let price: Double
    let supermarket: Supermarket
    let date: Date
}
