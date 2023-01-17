//
//  ScanBarcodeViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 5/12/2022.
//

import Foundation
import SwiftUI
import Combine

class ScanBarcodeViewModel: ObservableObject {
    
    @Published var product: Product
    @Published var cameraService: CameraService
    @Published var scanBarcode: ScanBarcodeService

    var anyCancellables = Set<AnyCancellable>()
    
    let viewDidLoad: () -> Void
    let viewDidUnload: () -> Void

    init(
        viewDidLoad: @escaping () -> Void,
        viewDidUnload: @escaping () -> Void
    ) {
        self.viewDidLoad = viewDidLoad
        self.viewDidUnload = viewDidUnload
        let product = Product()
        self._product = Published(wrappedValue: product)
        
        let cm = CameraService()
        let scanBarcode = ScanBarcodeService(cameraService: cm)
        
        self._cameraService = Published(wrappedValue: cm)
        self._scanBarcode = Published(wrappedValue: scanBarcode)
        
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
    }
    
    func onAppear() {
        scanBarcode.onAppear()
        viewDidLoad()
    }
    
    deinit {
        viewDidUnload()
        print("deinited AddProductViewModel and its view")
    }
}
