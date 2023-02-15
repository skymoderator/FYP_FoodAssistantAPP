//
//  CameraViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class CameraViewModel: ObservableObject {
    
    // MARK: - Services
    @Published var cameraService: CameraService
    @Published var pickerService = ImagePickerService()
    @Published var ntDetection = NutritionTableDetectionService()
    @Published var scanBarcode: ScanBarcodeService
    // MARK: - Photo Capture
    @Published var captureSource: CaptureSource?
    // MARK: - Camera Bottom Bar
    @Published var isScaleToFill: Bool = true
    // MARK: - Barcode Header
    @Published var barcode: String = ""
    @Published var isEditing = false
    // MARK: - Displayed Image View Header Buttons
    @Published var showSimilarProductView: Bool = false
    @Published var showAnalysisView: Bool = false
    // MARK: Cancellables to Store All Subscribers
    var anyCancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(cameraService: CameraService) {
        self._cameraService = Published(wrappedValue: cameraService)
        self._scanBarcode = Published(wrappedValue: ScanBarcodeService(cameraService: cameraService))
        
        scanBarcode.onAppear()
        
        cameraService.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)

        pickerService.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        ntDetection.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        scanBarcode.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &anyCancellables)
        
        scanBarcode.$barcode.sink { [weak self] (barcode: String) in
            withAnimation(.spring()) {
                self?.barcode = barcode
            }
        }
        .store(in: &anyCancellables)
    }
    
    // MARK: - Private Logic
    private func captureCameraPhoto() {
        cameraService.capturePhoto { [weak self] in
            guard let self = self,
                  let photo: Photo = self.cameraService.photo,
                  let resizedImage: UIImage = photo.resizedImage else { return }
            self.cameraService.stop {
                print("session stopped")
            }
            self.ntDetection.detectNuritionTable(image: resizedImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.captureSource = .byCamera
            }
        }
    }
    
    // MARK: - View Logic
    var displayedImage: UIImage? {
        if let captureSource {
            switch captureSource {
            case .byCamera:
                return cameraService.photo?.rescaledImage
            case .byImagePicker:
                return pickerService.photo?.rescaledImage
            }
        } else {
            return nil
        }
    }

    var resacledImageSize: CGSize {
        switch captureSource {
        case .none: return .zero
        case .some(let wrapped):
            switch wrapped {
            case .byCamera:
                return cameraService.photo?.rescaledImage?.size ?? .zero
            case .byImagePicker:
                return pickerService.photo?.rescaledImage?.size ?? .zero
            }
        }
    }
    
    func didSearchButtonCliced() {
        showSimilarProductView.toggle()
    }
    
    func didAnalysisButtonCliced() {
        showAnalysisView.toggle()
    }
    
    func onCameraPreviewTap() {
        UIApplication
            .shared
            .sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
    }
    
    func onXmarkButPressed() {
        withAnimation(.spring()) {
            scanBarcode.barcode = ""
        }
    }
    
    func onSnapButtonTapped() {
        if let captureSource {
            self.captureSource = nil
            switch captureSource {
            case .byImagePicker:
                pickerService.photo = nil
            case .byCamera:
                cameraService.photo = nil
            }
            cameraService.start()
        } else {
            captureCameraPhoto()
        }
    }
    
    func onTrailingButtonTapped() {
        if captureSource != nil {
            withAnimation(.easeInOut) {
                isScaleToFill.toggle()
            }
        } else {
            cameraService.changeCamera()
        }
    }
    
    func captureGalleryImage() {
        guard let resizedImage: UIImage = pickerService.photo?.resizedImage else { return }
        cameraService.stop()
        captureSource = .byImagePicker
        ntDetection.detectNuritionTable(image: resizedImage)
    }
    
    func displayImageGetter() -> UIImage? {
        displayedImage
    }


}
