//
//  FoodProductListViewModel.swift
//  FoodAssistant
//
//  Created by Elton Miao on 28/12/2022.
//

import Foundation
import Combine


class FoodProductListViewModel: ObservableObject{
    @Published var clicked = false
    @Published var vms = [FoodProductViewModel]()
//    @Published var alert = false
//    @Published var alert_message = ""
    private var api = FoodProductService(apiService: AppState.shared.apiService)
    private var subscriptions = Set<AnyCancellable>()
    
    init(){
        $clicked.throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { _ in
                self.loadData()
            }
            .store(in: &subscriptions)
    }
    
    func loadData(){
        let publisher = api.loadData()
        
        publisher.map({ foodProducts in
                foodProducts.map { foodProduct in
                    FoodProductViewModel(foodProduct: foodProduct)
                }
                })
        
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                switch completion {
                case let .failure(error):
                    print("Couldn't load food products: \(error)")
                case .finished: break
                }
            }) {  vms in //[weak self]
                self.vms = vms
                self.objectWillChange.send()
                print(self.vms)
            }
            .store(in: &subscriptions)
        
    }
    
    private func randomString(length: Int) -> String {
      let letters = "0123456789abcdefghijklmnopqrstuvwxyz"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func addData(foodProduct: Product){
        guard AppState.shared.authService.user != nil else {
            return
        }
        
        let publisher = api.addData(product: foodProduct)
        publisher.map({ snippet in
                       // snippets.map { snippet in
                            
                        return snippet
                       // }
                    })
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case let .failure(error):
                            print("Couldn't add food product: \(error)")
                        case .finished: break
                        }
                    }) { vm in
//                        self.vms.append(vm)
                        self.vms.append(FoodProductViewModel(foodProduct: vm))
                        self.objectWillChange.send()
                        print(vm)
                        
                        //self.vms = vms
                    }
                    .store(in: &subscriptions)
    }
    
}
