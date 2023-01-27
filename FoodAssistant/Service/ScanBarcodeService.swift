//
//  ScanBarcodeService.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class ScanBarcodeService: NSObject, ObservableObject {
    
    @Published var barcode: String = ""
    var cameraService: CameraService
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
        super.init()
    }
    
    func setUp() {
        cameraService.stop { [weak self] in
            guard let self = self else {
                print("optional self")
                return
            }
            self.cameraService.sessionQueue.async { [weak self] in
                guard let self = self else { return }
                let captureSession: AVCaptureSession = self.cameraService.session
                let metadataOutput = AVCaptureMetadataOutput()
                
                self.cameraService.session.beginConfiguration()
                
                if (captureSession.canAddOutput(metadataOutput)) {
                    captureSession.addOutput(metadataOutput)
                    
                    metadataOutput.setMetadataObjectsDelegate(self, queue: self.cameraService.sessionQueue)
                    metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
                } else {
                    print("failed to add metadata output to capture session, barcode detection may not work")
                }
                
                captureSession.commitConfiguration()
                self.cameraService.start()
            }
        }
    }
    
    func onAppear() {
        if cameraService.isConfigured {
            cameraService.start()
        } else {
            cameraService.configure(onComplete: setUp)
        }
    }
    
    func onDisappear() {
        cameraService.stop()
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
