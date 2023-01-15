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
    
    @Published var isPortrait: Bool = UIScreen.main.bounds.width < UIScreen.main.bounds.height
    
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
    
    func handlePageChange() {
        if bottomBarVM.currentPageNumber == .two {
            cameraService.start()
        } else {
            cameraService.stop()
        }
    }
    
    func handleDeviceOrientationChanges() {
        let offset: CGFloat = self.bottomBarVM.normalizedCurrentTabOffset.rounded()
        let pageNum: BottomBarViewModel.PageNumber = (offset == 0) ? .one : (offset == 1 ? .two : .three)
        self.bottomBarVM.scrollTo(page: pageNum, animated: true)
    }
        
    var screenWidth: CGFloat {
        let bound: CGRect = UIScreen.main.bounds
        let width: CGFloat = bound.width
        let height: CGFloat = bound.height
        if isPortrait {
            return min(width, height)
        } else {
            return max(width, height)
        }
    }
    
    var screenHeight: CGFloat {
        let bound: CGRect = UIScreen.main.bounds
        let width: CGFloat = bound.width
        let height: CGFloat = bound.height
        if isPortrait {
            return max(width, height)
        } else {
            return min(width, height)
        }
    }
    
    var screenSize: CGSize {
        .init(width: screenWidth, height: screenHeight)
    }
    
}
