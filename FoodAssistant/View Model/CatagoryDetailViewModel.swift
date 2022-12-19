//
//  CatagoryDetailViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/11/2022.
//

import SwiftUI

class CatagoryDetailViewModel: ObservableObject {
    
    @Published var _searchedProduct = ""
    
    var searchedProduct: Binding<String> {
        Binding<String>(get: {
            return self._searchedProduct
        }, set: { (s: String) in
            withAnimation(.spring()) {
                self._searchedProduct = s
            }
        })
    }
    
    let catagory: Catagory
    
    init(
        catagory: Catagory
    ) {
        self.catagory = catagory
    }
    
}
