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
    
    var anyCancellables = Set<AnyCancellable>()
    
    init() {
        let cm = CameraService()
        self._bottomBarVM = Published(wrappedValue: BottomBarViewModel())
        self._cameraService = Published(wrappedValue: cm)
        self._cvm = Published(wrappedValue: CameraViewModel(cameraService: cm))
        
        bottomBarVM.parent = self
        cameraService.configure()
        
        bottomBarVM.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
        .store(in: &anyCancellables)
        
        bottomBarVM.$pageChange.sink { [weak self] _ in
            self?.handlePageChange()
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
        
        AppState.shared.authService.getUserProfile()
    }
    
    var isCenterButMorphing: Bool {
        cvm.captureSource != nil
    }
    
    var isCameraViewCapturedPhotoScaleToFit: Bool {
        cvm.isScaleToFill
    }
    
    var isCameraViewPhotoCaptured: Bool {
        cvm.captureSource != nil
    }
    
    var isCameraViewFlashLightOn: Bool {
        cvm.cameraService.flashMode == .on
    }
    
    func handlePageChange() {
        if bottomBarVM.currentPageNumber == .two {
            cameraService.start()
        } else {
            cameraService.stop()
        }
    }
    
    func bottomTabBarOnLeadingButTap() {
        withAnimation {
            bottomBarVM.scrollTo(page: .one, animated: false)
        }
        handlePageChange()
    }
    
    func bottomTabBarOnCenterButTap() {
        if bottomBarVM.normalizedCurrentTabOffset != 1 {
            bottomBarVM.scrollTo(page: .two, animated: true)
            handlePageChange()
        } else {
            cvm.onSnapButtonTapped()
        }
    }
    
    func bottomTabBarOnTrailingButTap() {
        withAnimation {
            bottomBarVM.scrollTo(page: .three, animated: false)
        }
        handlePageChange()
    }
    
    func cameraBottomBarLeadingLeadingButTap() {
        cvm.pickerService.showImagePicker.toggle()
    }
    
    func cameraBottomBarLeadingButTap() {
        cvm.pickerService.showImagePicker.toggle()
    }
    
    func cameraBottomBarTrailingButTap() {
        cvm.onTrailingButtonTapped()
    }
    
    func cameraBottomBarTrailingTrailingButTap() {
        withAnimation(.spring()) {
            if cvm.cameraService.flashMode == .on {
                cvm.cameraService.flashMode = .off
            } else {
                cvm.cameraService.flashMode = .on
            }
        }
    }
    
    func onDeviceRotate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bottomBarVM.scrollTo(page: self.bottomBarVM.currentPageNumber, animated: false)
        }
    }
    
    func onScanBarcodeViewLoad() {
        withAnimation {
            bottomBarVM.showBar = false
            bottomBarVM.setSrollable(to: false)
        }

    }
    
    func onScanBarcodeViewUnload() {
        /*
         suprisingly deinit perform on main thread so no need
         to wrap the code in DispatchQueue.main.async
         */
        withAnimation {
            bottomBarVM.showBar = true
            bottomBarVM.setSrollable(to: true)
        }
    }
    
}
