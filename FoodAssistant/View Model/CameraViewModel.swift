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
    }
    
    // MARK: - Private Logic
    private func captureCameraPhoto() {
        cameraService.capturePhoto { [weak self] in
            guard let self = self,
                  let photo: Photo = self.cameraService.photo,
                  let image: UIImage = photo.image,
                  let resizedImage: UIImage = photo.resizedImage else { return }
            self.cameraService.stop { [weak self] in
                guard let self = self else { return }
                print("session stopped")
                self.ntDetection.detectNuritionTable(image: resizedImage)
                self.scanBarcode.detectBarcode(from: image, on: .byCamera)
                
                Task {
                    await MainActor.run { [weak self] in
                        self?.captureSource = .byCamera
                    }
                }
            }
        }
    }
    
    // MARK: - View Logic
    var displayedImage: UIImage? {
        if let captureSource {
            switch captureSource {
            case .byCamera:
                return cameraService.photo?.image
            case .byImagePicker:
                return pickerService.photo?.image
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
    
    /// Return the `InputProductDetailView.Detail` object assoicated with `Product` that contains
    /// the detected barcode string
    ///
    /// Pass the detected (editer from user-inputted or system-detected) barcode to the
    /// `InputProductDetailView` view via the type of `Product` so that the
    /// `InputProductDetailView` can be presented via sheet
    ///
    /// - Returns: An `InputProductDetailView.Detail` object
    var detail: InputProductDetailView.Detail {
        let product = Product(barcode: scanBarcode.barcode)
        return .init(product: product)
    }
    
    // - TODO: Show a page that search for similar product
    func didSearchButtonCliced() {
        showSimilarProductView.toggle()
    }
    
    /// Show the `InputProductDetailView` via sheet
    func didAnalysisButtonCliced() {
        showAnalysisView.toggle()
    }
    
    /// Dismiss keyboard when user taps on any area on the `CameraView`
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
    
    /// Clear the text in the barcode search textfield
    func onXmarkButPressed() {
        withAnimation(.spring()) {
            scanBarcode.barcode = ""
        }
    }
    
    /// Action to be triggered when user taps on the capture button at the middle of the `CameraBottomBar`
    ///
    /// When called, when there is currently no captured photo (either from camear or image picker),
    /// the function to capture the image from camera, otherwise it will reset the captured image and
    /// start the camera session again
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
            scanBarcode.barcode = ""
            scanBarcode.boundingBox = nil
            scanBarcode.normalizedBbox = nil
        } else {
            captureCameraPhoto()
        }
    }
    
    /// Action to be triggered when user has tapped the trailing button on the `CameraBottomBar`
    ///
    /// When called, when there is currently no captured photo (either from camear or image picker),
    /// the function will toggle the `isScaleToFill` published property, otherwise the function
    /// will perform call to change the camera (between front and back camera)
    func onTrailingButtonTapped() {
        if captureSource != nil {
            withAnimation(.easeInOut) {
                isScaleToFill.toggle()
            }
        } else {
            cameraService.changeCamera()
        }
    }
    
    /// Capture Gallert Image
    ///
    /// Call this function when user has tapped/selected an image from photo library
    /// The function will automatically look for the image from the `ImagePickerService`,
    /// so there is no need to pass the image to the function
    ///
    /// After getting the image, the function will detect barcode and nutrition table from the image
    func captureGalleryImage() {
        guard let photo: Photo = pickerService.photo,
              let resizedImage: UIImage = photo.resizedImage,
              let image: UIImage = photo.image
        else { return }
        cameraService.stop()
        captureSource = .byImagePicker
        ntDetection.detectNuritionTable(image: resizedImage)
        
//        let result: String? = scanBarcode.detectBarcode(from: image)
//        if let result {
//            scanBarcode.barcode = result
//        }
        scanBarcode.detectBarcode(from: image, on: .byImagePicker)
    }
}
