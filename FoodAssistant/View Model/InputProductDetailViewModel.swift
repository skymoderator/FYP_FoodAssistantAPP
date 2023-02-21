//
//  InputProductDetailViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/1/2023.
//

import Foundation

class InputProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var boundingBox: BoundingBox?
    @Published var nutritionTablePhoto: Photo?
    
    init(
        product: Product,
        boundingBox: BoundingBox?,
        nutritionTablePhoto: Photo?
    ) {
        self._product = Published(wrappedValue: product)
        self._boundingBox = Published(wrappedValue: boundingBox)
        self._nutritionTablePhoto = Published(wrappedValue: nutritionTablePhoto)
    }
    
    func onScanNutTableButTap() {
        
    }
}
