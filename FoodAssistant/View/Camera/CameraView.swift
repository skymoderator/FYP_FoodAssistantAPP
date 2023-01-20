//
//  CameraView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct CameraView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    let view = VideoPreviewView()
    let screenSize: CGSize
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            ZStack {
                if let image: UIImage = mvm.cvm.displayedImage {
                    DisplayedImageView(
                        image: image,
                        isScaleToFill: mvm.cvm.isScaleToFill,
                        bboxes: mvm.cvm.ntDetection.boundingBoxes,
                        rescaledImageSize: mvm.cvm.resacledImageSize
                    )
                } else {
                    CameraPreview(session: mvm.cvm.cameraService.session)
                        .overlay(alignment: .top) {
                            Header()
                        }
                }
                Color.black
                    .opacity(mvm.cvm.cameraService.willCapturePhoto ? 1 : 0)
            }
            .frame(width: size.width, height: size.height)
        }
        .frame(width: screenSize.width, height: screenSize.height)
        .clipped()
        .edgesIgnoringSafeArea(.all)
        .sheet(
            isPresented: $mvm.cvm.pickerService.showImagePicker,
            onDismiss: mvm.cvm.captureGalleryImage
        ) {
            ImagePicker(image: $mvm.cvm.pickerService.image, camera: false)
        }
    }
}

fileprivate struct Header: View {
    @Environment(\.safeAreaInsets) var safeArea
    var body: some View {
        HStack {
            Image(systemName: "barcode.viewfinder")
            Text("Scan Barcode")
        }
        .productFont(.bold, relativeTo: .title2)
        .foregroundColor(.primary)
        .padding(12)
        .padding(.horizontal)
        .background {
            Capsule()
                .fill(.thickMaterial)
                .shadow(radius: 30)
        }
        .padding(.top, safeArea.top)
        .padding(.top)
        .transition(.move(edge: .top))
    }
}

fileprivate struct DisplayedImageView: View {
    
    let image: UIImage
    let isScaleToFill: Bool
    let bboxes: [BoundingBox]
    let rescaledImageSize: CGSize
    
    var body: some View {
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: isScaleToFill ? .fill : .fit)
            .overlay {
                GeometryReader { (proxy: GeometryProxy) in
                    let size: CGSize = proxy.size
                    BoundingBoxView(
                        boundingBoxes: bboxes,
                        size: size,
                        rescaledSize: rescaledImageSize
                    )
                }
            }
    }
}

struct CameraView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let size: CGSize = proxy.size
//            CameraView(screenSize: size)
//        }
        ContentView()
        .environmentObject(mvm)
    }
}
