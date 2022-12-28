//
//  ProductViewModel.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation


class FoodProductViewModel: ObservableObject{
    @Published var foodProduct: Product
    
    init(foodProduct: Product){
        self.foodProduct = foodProduct
        print(self.foodProduct)
    }
}
