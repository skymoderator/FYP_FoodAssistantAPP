//
//  CameraView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct CameraView: View {
    
//    @EnvironmentObject var mvm: MainViewModel
    @ObservedObject var cvm: CameraViewModel
    let view = VideoPreviewView()
    let screenSize: CGSize
    
    init(
        cameraViewModel: CameraViewModel,
        screenSize: CGSize
    ) {
        self._cvm = ObservedObject(wrappedValue: cameraViewModel)
        self.screenSize = screenSize
    }
    
    var body: some View {
        ZStack {
            if let image: UIImage = cvm.displayedImage {
                DisplayedImageView(
                    image: image,
                    isScaleToFill: cvm.isScaleToFill,
                    bboxes: cvm.ntDetection.boundingBoxes,
                    rescaledImageSize: cvm.resacledImageSize
                )
            } else {
                CameraPreview(session: cvm.cameraService.session)
                    .onTapGesture(perform: cvm.onCameraPreviewTap)
                    .overlay(alignment: .top) {
                        Header(barcode: $cvm.barcode)
                    }
            }
            Color.black
                .opacity(cvm.cameraService.willCapturePhoto ? 1 : 0)
        }
        .frame(width: screenSize.width, height: screenSize.height)
        .clipped()
        .edgesIgnoringSafeArea(.all)
        .sheet(
            isPresented: $cvm.pickerService.showImagePicker,
            onDismiss: cvm.captureGalleryImage
        ) {
            ImagePicker(image: $cvm.pickerService.image, camera: false)
        }
    }
}

fileprivate struct Header: View {
    @Environment(\.safeAreaInsets) var safeArea
    @Binding var barcode: String
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(.systemBlue)
                TextField(text: Binding<String>(
                    get: { barcode },
                    set: { (s: String, _) in
                        withAnimation(.spring()) {
                            barcode = s
                        }
                    }
                ))
                .keyboardType(.numberPad)
                .overlay(alignment: .leading) {
                    if barcode.isEmpty {
                        Text("Product Barcode")
                            .allowsHitTesting(false)
                    }
                }
                .overlay(alignment: .trailing) {
                    Button {
                        withAnimation(.spring()) {
                            barcode = ""
                        }
                    } label: {
                        Circle()
                            .fill(.ultraThickMaterial)
                            .overlay {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(8)
                                    .foregroundColor(.primary)
                            }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.thinMaterial)
            }
            .zIndex(1)
            if !barcode.isEmpty {
                Button {
                    
                } label: {
                    Text("Search")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.systemBlue)
                        .cornerRadius(20, style: .continuous)
                }
                .opacity(barcode.isEmpty ? 0 : 1)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top),
                        removal: .identity)
                )
                .zIndex(0)
            }
        }
        .productFont(.bold, relativeTo: .title2)
        .foregroundColor(.primary)
        .padding(.horizontal)
        .padding(.top, safeArea.top)
        .padding(.vertical)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
        }
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
