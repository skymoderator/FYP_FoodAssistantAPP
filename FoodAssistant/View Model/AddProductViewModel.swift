//
//  AddProductViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 5/12/2022.
//

import Foundation
import SwiftUI
import Combine

class AddProductViewModel: ObservableObject {
    
    @Published var product: Product
    @Published var cameraService: CameraService
    @Published var scanBarcode: ScanBarcodeService
    @Published var mvm: MainViewModel?

    var anyCancellables = Set<AnyCancellable>()
    
    @Published var showView = true

    init(mvm: MainViewModel? = nil) {
        let product = Product()
        self._product = Published(wrappedValue: product)
        
        let cm = CameraService()
        let scanBarcode = ScanBarcodeService(cameraService: cm)
        
        self._mvm = Published(wrappedValue: mvm)
        self._cameraService = Published(wrappedValue: cm)
        self._scanBarcode = Published(wrappedValue: scanBarcode)
        
        self.mvm?.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        self.cameraService.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)

        self.scanBarcode.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        self.scanBarcode.$barcode.sink { [weak self] in
            self?.product.barcode = $0
        }
        .store(in: &anyCancellables)
    
        DispatchQueue.main.async {
            withAnimation {
                mvm?.bottomBarVM.showBar = false
                mvm?.bottomBarVM.scrollable = false
            }
        }
    }
    
    deinit {
        /*
         suprisingly deinit perform on main thread so no need
         to wrap the code in DispatchQueue.main.async
         */
        withAnimation {
            self.mvm?.bottomBarVM.showBar = true
            self.mvm?.bottomBarVM.scrollable = true
        }
        print("deinited AddProductViewModel and its view")
    }
}
