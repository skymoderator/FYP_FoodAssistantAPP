//
//  InventoryViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 25/3/2023.
//

import Foundation
import Combine

class InventoryViewModel: ObservableObject {
    @Published var foodDataService: FoodProductDataService
    @Published var inventories: [Inventory]
    @Published var searchingText: String
    @Published var editingInventory: Inventory?
    @Published var summaryType: SummaryCategory? = nil
    
    var anyCancellables = Set<AnyCancellable>()
    init(dataSource: FoodProductDataService) {
        searchingText = ""
        /// Note: Check if there is any inventory in the user defaults
        /// If there is, load it, otherwise, create a new one
        do {
            if let data: Data = UserDefaults.standard.object(forKey: "inventories") as? Data {
               let inventories: [Inventory] = try JSONDecoder().decode([Inventory].self, from: data)
                self.inventories = inventories
            } else {
                self.inventories = []
            }
        } catch {
            print(error)
            self.inventories = []
        }
        
        self._foodDataService = Published(wrappedValue: dataSource)
        foodDataService.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
    }
    
    func updateInventories() {
        if let encoded: Data = try? JSONEncoder().encode(inventories) {
            UserDefaults.standard.set(encoded, forKey: "inventories")
        }
    }
    
    deinit {
        updateInventories()
    }
}

extension InventoryViewModel {
    enum SummaryCategory: String, CaseIterable {
        case energy = "Energy"
        case sugar = "Sugar"
        case carbohydrates = "Carbohydrates"
    }
}
