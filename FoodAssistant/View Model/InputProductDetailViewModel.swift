//
//  InputProductDetailViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/1/2023.
//

import Foundation

class InputProductDetailViewModel: ObservableObject {
    @Published var product: Product
    
    init(product: Product) {
        self._product = Published(wrappedValue: product)
    }
    
    func onScanNutTableButTap() {
        
    }
}
