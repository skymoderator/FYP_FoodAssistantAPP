//
//  ProductViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/11/2022.
//

import Foundation
import SwiftUI
import Combine

class CatagoryViewModel: ObservableObject {
    
    @Published private var _searchedCatagory = ""
    @Published var foodsService = FoodProductDataService()
    
    var searchedCatagory: Binding<String> {
        Binding<String>(get: {
            self._searchedCatagory
        }, set: { (s: String) in
            withAnimation(.spring()) {
                self._searchedCatagory = s
            }
        })
    }
    
    var anyCancellables = Set<AnyCancellable>()
    
    var filteredCats: [String] {
        if _searchedCatagory.isEmpty {
            return foodsService.categories1
        } else {
            return foodsService.categories1.filter { (cat: String) in
                cat.lowercased().contains(_searchedCatagory.lowercased())
            }
        }
    }
    
    init() {
        foodsService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
    }
    
}
