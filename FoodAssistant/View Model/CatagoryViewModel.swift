//
//  ProductViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/11/2022.
//

import Foundation
import SwiftUI

class CatagoryViewModel: ObservableObject {
    
    @Published var _searchedCatagory = ""
    
    var searchedCatagory: Binding<String> {
        Binding<String>(get: {
            return self._searchedCatagory
        }, set: { (s: String) in
            withAnimation(.spring()) {
                self._searchedCatagory = s
            }
        })
    }
    
    var filteredCats: [Catagory] {
        if _searchedCatagory.isEmpty {
            return Catagory.allCases
        } else {
            return Catagory.allCases.filter { (cat: Catagory) in
                cat.rawValue.contains(_searchedCatagory)
            }
        }
    }
    
}
