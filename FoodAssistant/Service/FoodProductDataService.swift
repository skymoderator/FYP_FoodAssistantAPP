//
//  FoodProductService.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import Combine

class FoodProductDataService: ObservableObject {
    
    @Published var clicked = false
    @Published var products: [Product] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $clicked
            .throttle(
                for: .seconds(1),
                scheduler: DispatchQueue.main,
                latest: true
            )
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &subscriptions)
    }
    
    func loadData() {
        AppState
            .shared
            .dataService
            .get(
                type: [Product].self,
                path: "/api/foodproducts/"
            )
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case let .failure(error):
                    print("Couldn't load food products: \(error)")
                case .finished: break
                }
            } receiveValue: { [weak self] (products: [Product]) in
                self?.products = products
                print("Successfully loaded \(products.count) food products.")
            }
            .store(in: &subscriptions)
    }
    
    func addData(product: Product) {
        if AppState.shared.authService.user == nil { return }
        
        AppState
            .shared
            .dataService
            .post(
                object: product,
                type: Product.self,
                path: "/api/foodproducts/"
            )
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                switch completion {
                case let .failure(error):
                    print("Couldn't add food product: \(error)")
                case .finished: break
                }
            } receiveValue: { [weak self] (product: Product) in
                self?.products.append(product)
            }
            .store(in: &subscriptions)
    }
    
    func putData(product: Product) -> AnyPublisher<Product, Error> {
        AppState
            .shared
            .dataService
            .put(
                object: product,
                type: Product.self,
                path: "/api/foodproducts/\(product.id)"
            )
    }
}
