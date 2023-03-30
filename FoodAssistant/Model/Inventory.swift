//
//  Inventory.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 25/3/2023.
//

import Foundation

struct Inventory: IdentifyEquateCodeHashable {
    let id = UUID()
    var name: String
    var description: String?
    var products: [Product]
    
    init() {
        name = "Untitled List"
        description = nil
        products = []
    }
    
    init(
        name: String,
        description: String?,
        products: [Product]
    ) {
        self.name = name
        self.description = description
        self.products = products
    }
}
