//
//  ScanBarcodeService.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import Vision

class ScanBarcodeService: NSObject, ObservableObject {
    
    /// Note:
    /// This `barcode` property can either be changed by
    /// - the functon `processClassification` whenever a new barcode has been detected by `Vision`
    /// - the textfield on the header in `CameraView`
    /// The new value will replace the old value, so the user-inputted barcode maybe replaced by newly detected
    /// barcode when `Vision` has detected a new barcode on the screen
    @Published var barcode: String = ""
    @Published var errorMessage: String?
    @Published var boundingBox: CGRect?
    
    var cameraService: CameraService
    
    let detectBarcodeRequest = VNDetectBarcodesRequest()

    init(cameraService: CameraService) {
        self.cameraService = cameraService
        super.init()
        
        setUpBarcodeRequest()
    }
    
    private func setUp(captureSession: AVCaptureSession, sessionQueue: DispatchQueue) {
//        let metadataOutput = AVCaptureMetadataOutput()
//
//        if (captureSession.canAddOutput(metadataOutput)) {
//            captureSession.addOutput(metadataOutput)
//
//            metadataOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
//            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
//        } else {
//            print("failed to add metadata output to capture session, barcode detection may not work")
//        }
    }
    
    private func setUpBarcodeOutput(
        captureSession: AVCaptureSession,
        captureOutput: AVCaptureVideoDataOutput,
        sessionQueue: DispatchQueue
    ) {
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    }
    
    private func processClassification(imageSize: CGSize) {
        guard let observations: [VNBarcodeObservation] = detectBarcodeRequest.results,
              let observation: VNBarcodeObservation = observations.first
        else {
            if barcode.isEmpty || boundingBox == nil {
                return
            }
            Task {
                await MainActor.run {
                    barcode = ""
                    boundingBox = nil
                }
            }
            return
        }
        
//            print(observation.payloadStringValue ?? "unknown barcode")
//            print(observation.boundingBox)
            
        let convertedRect: CGRect = self.getConvertedRect(
            boundingBox: observation.boundingBox,
            inImage: imageSize,
            containedIn: UIScreen.protraitSize
        )
        Task {
            await MainActor.run {
                var convertedRect = convertedRect
                let orientation: UIInterfaceOrientation = UIApplication
                    .shared
                    .connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                    .first?
                    .windowScene?
                    .interfaceOrientation ?? .portrait
                if orientation == .landscapeRight {
                    // Rotate the rect by 90 degrees clockwise
                    convertedRect = CGRect(
                        x: convertedRect.origin.y,
                        y: UIScreen.protraitSize.width - convertedRect.origin.x - convertedRect.width,
                        width: convertedRect.height,
                        height: convertedRect.width
                    )
                } else if orientation == .landscapeLeft {
                    // Rotate the rect by 90 degrees counter-clockwise
                    convertedRect = CGRect(
                        x: UIScreen.protraitSize.height - convertedRect.origin.y - convertedRect.height,
                        y: convertedRect.origin.x,
                        width: convertedRect.height,
                        height: convertedRect.width
                    )
                }
                boundingBox = convertedRect
                
                guard let newBarcode: String = observation.payloadStringValue,
                      newBarcode != barcode
                else { return }
                barcode = newBarcode
            }
        }
    }
    
    private func setUpBarcodeRequest() {
        detectBarcodeRequest.symbologies = [.ean8, .ean13, .pdf417]
    }
    
    private func getConvertedRect(
        boundingBox: CGRect,
        inImage imageSize: CGSize, // 1920x1080
        containedIn containerSize: CGSize // 428x926 or 926x428
    ) -> CGRect {
        let rectOfImage: CGRect
        
        let imageAspect = imageSize.width / imageSize.height // 1.78
        let containerAspect = containerSize.width / containerSize.height // 0.46
        
        if imageAspect > containerAspect { /// image extends left and right
            let newImageWidth = containerSize.height * imageAspect /// the width of the overflowing image
            let newX = -(newImageWidth - containerSize.width) / 2
            rectOfImage = CGRect(x: newX, y: 0, width: newImageWidth, height: containerSize.height)
            
        } else { /// image extends top and bottom
            let newImageHeight = containerSize.width * (1 / imageAspect) /// the width of the overflowing image
            let newY = -(newImageHeight - containerSize.height) / 2
            rectOfImage = CGRect(x: 0, y: newY, width: containerSize.width, height: newImageHeight)
        }
        
        let newOriginBoundingBox = CGRect(
        x: boundingBox.origin.x,
        y: 1 - boundingBox.origin.y - boundingBox.height,
        width: boundingBox.width,
        height: boundingBox.height
        )
        
        var convertedRect = VNImageRectForNormalizedRect(newOriginBoundingBox, Int(rectOfImage.width), Int(rectOfImage.height))
        
        /// add the margins
        convertedRect.origin.x += rectOfImage.origin.x
        convertedRect.origin.y += rectOfImage.origin.y
        
        return convertedRect
    }
    
    func onAppear() {
//        if cameraService.isConfigured {
//            cameraService.start()
//        } else {
//            cameraService.configure(duringConfigure: setUp)
//        }
        cameraService.configure(additionalInput: setUp, additionalOutput: setUpBarcodeOutput)
    }
    
    func onDisappear() {
        cameraService.stop()
    }
    
    /// Detect barcode from an image
    /// 
    /// - Parameters:
    ///   - image: an UIImage object to be detected from
    ///
    /// - Returns: An optional string of the barcode if detected, otherwise nil
    func detectBarcode(from image: UIImage) -> String? {
        guard let cgImage: CGImage = image.cgImage else { return nil }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
            return nil
        }
        
        guard let observations: [VNBarcodeObservation] = detectBarcodeRequest.results,
              let observation: VNBarcodeObservation = observations.first
        else { return nil }
        
        return observation.payloadStringValue
    }
    
    deinit {
        print("deinited ScanBarcodeService")
    }
    
}

extension ScanBarcodeService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard barcode.isEmpty,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue
        else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        DispatchQueue.main.async { [weak self] in
            self?.barcode = stringValue
        }
    }
}

extension ScanBarcodeService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let uiImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: .right)
        let imageRequestHandler = VNImageRequestHandler(
          cvPixelBuffer: pixelBuffer,
          orientation: .right
        )

        do {
          try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }
        
        processClassification(imageSize: uiImage.size)
    }
}
