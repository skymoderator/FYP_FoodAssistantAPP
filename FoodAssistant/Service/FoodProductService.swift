//
//  FoodProductService.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Combine

class FoodProductService{
    
    private var apiService: APIEngine
    var subscriptions = Set<AnyCancellable>()
    
    init(apiService: APIEngine){
        self.apiService = apiService
    }
    
    func loadData() -> AnyPublisher<[Product], Error>{
        
       return apiService.get(type: [Product].self, path: "/api/foodproducts/")

    }
    
//    func loadData(id: String) -> AnyPublisher<Product, Error>{
//
//       return apiService.get(type: Product.self, path: "/api/foodproducts/\(id)")
//
//    }
    
    func addData(product: Product) -> AnyPublisher<Product, Error>{
        
        return apiService.post(object: product, type: Product.self, path: "/api/foodproducts/")

    }
    
    func putData(product: Product) -> AnyPublisher<Product, Error>{
        return apiService.put(object: product, type: Product.self, path: "/api/foodproducts/\(product.id)")
    }
    
}
