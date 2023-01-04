//
//  CatagoryDetailViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 3/1/2023.
//

import Foundation
import SwiftUI

class CatagoryDetailViewModel: ObservableObject {
    
    // MARK: Character Model For Holding Data about Each Alphabet
    class ProductCharacter: Identifiable {
        var uuid: String = UUID().uuidString
        var value: String
        var index: Int = 0
        var rect: CGRect = .zero
        var pusOffset: CGFloat = 0
        var isCurrent: Bool = false
        var products: [Product] = []

        init(value: String) {
            self.value = value
        }
    }
    
    @Published private var _searchedProduct = ""
    @Published var characters: [ProductCharacter] = []
    @Published var scrollerHeight: CGFloat = 0
    @Published var startOffset: CGFloat = 0
    @Published var hideIndicatorLabel: Bool = false
    @Published var currentCharacter: ProductCharacter? = nil
    @Published var indicatorOffset: CGFloat = 0
    @Published var scrollerTimeOut: CGFloat = 0.3
    let products: [Product]
    
    init(products: [Product]) {
        self.products = products
        
        let alphabet: [String] = Array(Set(products.map { (p: Product) in
            String(p.name.prefix(1))
        })).sorted()
        self.characters = alphabet.map { (s: String) in
            ProductCharacter(value: s)
        }
        for index in 0..<self.characters.count {
            self.characters[index].index = index
            self.characters[index].products = products.filter { (p: Product) in
                p.name.lowercased().starts(with: self.characters[index].value.lowercased())
            }
        }
    }
    
    var searchedProduct: Binding<String> {
        Binding<String>(get: {
            self._searchedProduct
        }, set: { (s: String) in
            withAnimation(.spring()) {
                self._searchedProduct = s
            }
        })
    }
    
    var filteredProducts: [Product] {
        if self._searchedProduct.isEmpty {
            return products
        } else {
            return products.filter { (p: Product) in
                p.name.lowercased().contains(self._searchedProduct.lowercased())
            }
        }
    }

}
