//
//  CameraPreview.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 8/11/2022.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreview: UIViewRepresentable {
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(_ uiView: VideoPreviewView, context: Context) {

    }
    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView()
//        let layer = AVCaptureVideoPreviewLayer(session: session)
//        let bounds: CGRect = UIScreen.main.bounds
//        layer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        layer.videoGravity = .resizeAspectFill
//        layer.connection?.videoOrientation = .portrait
//        view.layer.addSublayer(layer)
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//
//    }
}
