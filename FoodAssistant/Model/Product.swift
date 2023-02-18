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
    let photo: Photo?
    let ntBoundingBox: BoundingBox?
    
    init(
        name: String = "",
        barcode: String = "",
        nutrition: NutritionInformation? = nil,
        manufacturer: String? = nil,
        brand: String? = nil,
        prices: [ProductPrice] = [],
        category1: String? = nil,
        category2: String? = nil,
        category3: String? = nil,
        photo: Photo? = nil,
        ntBoundingBox: BoundingBox? = nil
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
        self.photo = photo
        self.ntBoundingBox = ntBoundingBox
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        barcode = try container.decode(String.self, forKey: .barcode)
        nutrition = try container.decode(NutritionInformation.self, forKey: .nutrition)
        manufacturer = try container.decode(String.self, forKey: .manufacturer)
        brand = try container.decode(String.self, forKey: .brand)
        prices = try container.decode([ProductPrice].self, forKey: .prices)
        category1 = try container.decode(String.self, forKey: .category1)
        category2 = try container.decode(String.self, forKey: .category2)
        category3 = try container.decode(String.self, forKey: .category3)
        /// convert base64 string to UIImage
        if let base64String: String = try container.decodeIfPresent(String.self, forKey: .photo),
           let imageData: Data = Data(base64Encoded: base64String),
           let image: UIImage = UIImage(data: imageData) {
            photo = Photo(image: image)
        } else {
            photo = nil
        }
        ntBoundingBox = try container.decode(BoundingBox.self, forKey: .ntBoundingBox)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(nutrition, forKey: .nutrition)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(brand, forKey: .brand)
        try container.encode(prices, forKey: .prices)
        try container.encode(category1, forKey: .category1)
        try container.encode(category2, forKey: .category2)
        try container.encode(category3, forKey: .category3)
        /// convert UIImage to base64 string
        if let photo: Photo = photo,
           let imageData: Data = photo.image?.jpegData(compressionQuality: 1.0) {
            let base64String: String = imageData.base64EncodedString()
            try container.encode(base64String, forKey: .photo)
        }
        try container.encode(ntBoundingBox, forKey: .ntBoundingBox)
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
        case photo = "photo"
        case ntBoundingBox = "ntBoundingBox"
    }
}

struct ProductPrice: Hashable, Codable {
    let price: Double
    let supermarket: Supermarket
    let date: Date
}
