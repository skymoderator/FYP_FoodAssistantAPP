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
    @Published var cvm: CameraViewModel
    
    var anyCancellables = Set<AnyCancellable>()
    
    init() {
        let cm = CameraService()
        self._bottomBarVM = Published(wrappedValue: BottomBarViewModel())
        self._cvm = Published(wrappedValue: CameraViewModel(cameraService: cm))
        
        bottomBarVM.objectWillChange.sink { [weak self] _ in
            // Because device rotation is not perform on main thread
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
        .store(in: &anyCancellables)
        
        bottomBarVM.$pageChange.sink { [weak self] _ in
            self?.handlePageChange()
        }
        .store(in: &anyCancellables)
        
        cvm.objectWillChange.sink { [weak self] in
            self?.bottomBarVM.objectWillChange.send()
        }
        .store(in: &anyCancellables)
                
//        AppState.shared.authService.getUserProfile()
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
        if bottomBarVM.currentPageNumber == .two,
           // If there is already a photo captured,
           // then no need to start the camera session again
            cvm.captureSource == nil
        {
            cvm.cameraService.start()
            print("start, \(bottomBarVM.currentPageNumber)")
        } else {
            cvm.cameraService.stop()
            print("stop, \(bottomBarVM.currentPageNumber)")
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
            bottomBarVM.scrollTo(page: .two, animated: false)
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
            bottomBarVM.objectWillChange.send()
        }
    }
    
    func onDeviceRotate(
        oldScreenSize: CGSize,
        orientation: UIDeviceOrientation
    ) {
        guard
            orientation == .landscapeRight ||
            orientation == .landscapeLeft ||
            orientation == .portrait
        else { return }
        let width: CGFloat = oldScreenSize.width
        let height: CGFloat = oldScreenSize.height
        let min: CGFloat = min(width, height)
        let max: CGFloat = max(width, height)
        let singlePageWidth: CGFloat = orientation.isPortrait ? min : max
        bottomBarVM.viewWidth = singlePageWidth
        bottomBarVM.scrollTo(
            page: bottomBarVM.currentPageNumber,
            animated: false
        )
        // Since rotation may cause page change
        // although it shouldn't be
        handlePageChange()
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
    
    func onCameraViewPhotoCaptured() {
        bottomBarVM.setSrollable(to: false)
    }
    
    func onCameraViewPhotoReleased() {
        bottomBarVM.setSrollable(to: true)
    }
    
}
