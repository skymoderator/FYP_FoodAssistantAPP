//
//  CameraView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct CameraView: View {
    
    @ObservedObject var cvm: CameraViewModel
    let screenSize: CGSize
        
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
                        Header(
                            barcode: $cvm.barcode,
                            onXmarkButPressed: cvm.onXmarkButPressed
                        )
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
    let onXmarkButPressed: () -> Void
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
                    Button(action: onXmarkButPressed) {
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
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
//    @State private var offset: CGSize = .zero
//    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View {
        Image(uiImage: image)
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
            .scaleEffect(scale)
//            .offset(offset)
//            .gesture(
//                DragGesture()
//                    .updating($isInteracting, body: { _, out, _ in
//                        out = true
//                    }).onChanged({ value in
//                        let translation = value.translation
//                        offset = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
//                    })
//            )
            .gesture(
                MagnificationGesture()
                    .updating($isInteracting, body: { _, out, _ in
                        out = true
                    }).onChanged({ value in
                        let updatedScale = value + lastScale
                        /// - Limiting Beyond 1
                        scale = (updatedScale < 1 ? 1 : updatedScale)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.2)){
                            if scale < 1{
                                scale = 1
                                lastScale = 0
                            }else{
                                lastScale = scale - 1
                            }
                        }
                    })
            )
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
