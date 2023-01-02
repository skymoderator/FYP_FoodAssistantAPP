//
//  MainViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    
    @Published var bottomBarVM: BottomBarViewModel
    @Published var cameraService: CameraService
    @Published var cvm: CameraViewModel
    @Published var foodsService = FoodProductDataService()
    
    var anyCancellables = Set<AnyCancellable>()
    
    init() {
        let cm = CameraService()
        self._bottomBarVM = Published(wrappedValue: BottomBarViewModel())
        self._cameraService = Published(wrappedValue: cm)
        self._cvm = Published(wrappedValue: CameraViewModel(cameraService: cm))
        
        cameraService.configure()
        
        bottomBarVM.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        cvm.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        cameraService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        foodsService.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        AppState.shared.authService.getUserProfile()
    }
    
}
