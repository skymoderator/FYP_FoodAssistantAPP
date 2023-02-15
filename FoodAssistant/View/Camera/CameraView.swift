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
            if cvm.captureSource != nil {
                DisplayedImageView(
                    image: cvm.displayImageGetter,
                    isScaleToFill: $cvm.isScaleToFill,
                    bboxes: cvm.ntDetection.boundingBoxes,
                    rescaledImageSize: cvm.resacledImageSize,
                    screenSize: screenSize,
                    didSearchButtonCliced: cvm.didSearchButtonCliced,
                    didAnalysisButtonCliced: cvm.didAnalysisButtonCliced
                )
            } else {
                CameraPreview(session: cvm.cameraService.session)
                    .overlay(alignment: .topLeading) {
                        if let bbox: CGRect = cvm.scanBarcode.boundingBox {
                            BarCodeIndicatorView(
                                barcode: cvm.scanBarcode.barcode,
                                width: bbox.width,
                                height: bbox.height,
                                offset: bbox.origin
                            )
                            .animation(.easeIn, value: cvm.scanBarcode.boundingBox)
                        }
                    }
                    .onTapGesture(perform: cvm.onCameraPreviewTap)
                    .overlay(alignment: .top) {
                        BarcodeHeader(
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
        .sheet(isPresented: $cvm.showAnalysisView) {
            let detail: InputProductDetailView.Detail = .init(product: Product())
            // Note:
            // The InputProductDetailView itself does not contain NavigationStack
            // therefore, it is the parent view's (this view) responsibility to
            // embed InputProductDetailView to NavigationStack so that the
            // navigation bar and large navigation title can display properly
            NavigationStack {
                InputProductDetailView(detail: detail)
            }
        }
    }
}

fileprivate struct BarcodeHeader: View {
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
                    .hoverEffect()
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
                .hoverEffect()
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
    let image: () -> UIImage?
    @Binding var isScaleToFill: Bool
    let bboxes: [BoundingBox]
    let rescaledImageSize: CGSize
    let screenSize: CGSize
    let didSearchButtonCliced: (() -> Void)?
    let didAnalysisButtonCliced: (() -> Void)?
    
    var body: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let size: CGSize = proxy.size
//            Image(uiImage: image)
//                .resizable()
//                .aspectRatio(contentMode: isScaleToFill ? .fill : .fit)
//                .overlay {
//                    GeometryReader { (proxy: GeometryProxy) in
//                        let size: CGSize = proxy.size
//                        BoundingBoxView(
//                            boundingBoxes: bboxes,
//                            size: size,
//                            rescaledSize: rescaledImageSize
//                        )
//                    }
//                }
//        }
        ZoomableScrollView(
            image: image,
            isScaleToFill: $isScaleToFill,
            size: screenSize
        )
        .frame(width: screenSize.width, height: screenSize.height)
        .overlay(alignment: .top) {
            Header(
                didSearchButtonCliced: didSearchButtonCliced,
                didAnalysisButtonCliced: didAnalysisButtonCliced
            )
        }
    }
    
    fileprivate struct Header: View {
        @Environment(\.safeAreaInsets) var safeArea
        let didSearchButtonCliced: (() -> Void)?
        let didAnalysisButtonCliced: (() -> Void)?
        var body: some View {
            HStack {
                Button {
                    didSearchButtonCliced?()
                } label: {
                    VStack {
                        Image(systemName: "magnifyingglass.circle")
                        Text("Search")
                            .productFont(.bold, relativeTo: .title3)
                    }
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .hoverEffect()
                Button {
                    didAnalysisButtonCliced?()
                } label: {
                    VStack {
                        Image(systemName: "tablecells.badge.ellipsis")
                        Text("Analysis")
                            .productFont(.bold, relativeTo: .title3)
                    }
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .hoverEffect()
            }
            .buttonStyle(.plain)
            .padding(.top, safeArea.top)
            .padding()
            .background(.thinMaterial, in: Rectangle())
            .transition(.move(edge: .top))
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
        ContentView()
        .environmentObject(mvm)
    }
}
