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
    
    @State private var isBarCodeIndicatorViewAppear: Bool = false
        
    var body: some View {
        ZStack {
            if cvm.captureSource != nil {
                DisplayedImageView(
                    image: cvm.displayedImage ?? UIImage(),
                    isScaleToFill: $cvm.isScaleToFill,
//                    bboxes: cvm.ntDetection.boundingBoxes,
//                    rescaledImageSize: cvm.resacledImageSize,
                    screenSize: screenSize,
                    barcode: cvm.scanBarcode.barcode,
                    normalizedBarcodeBBox: cvm.scanBarcode.normalizedBbox,
                    didSearchButtonCliced: cvm.didSearchButtonCliced,
                    didAnalysisButtonCliced: cvm.didAnalysisButtonCliced,
                    convertNormalizedBBoxToRectInSpecificView: cvm.scanBarcode.getConvertedRect,
                    convertImage: cvm.scanBarcode.convertImage,
                    transform: cvm.scanBarcode.transform
                )
            } else {
                CameraPreview(session: cvm.cameraService.session)
                    .overlay(alignment: .topLeading) {
                        if let bbox: CGRect = cvm.scanBarcode.boundingBox {
                            BarCodeIndicatorView(
                                barcode: cvm.scanBarcode.barcode,
                                width: bbox.width,
                                height: bbox.height,
                                offset: bbox.origin,
                                isAppeared: $isBarCodeIndicatorViewAppear
                            )
                            .onAppear { isBarCodeIndicatorViewAppear = true }
                            .onDisappear { isBarCodeIndicatorViewAppear = false }
                            .animation(.easeIn, value: cvm.scanBarcode.boundingBox)
                        }
                    }
                    .onTapGesture(perform: cvm.onCameraPreviewTap)
                    .overlay(alignment: .top) {
                        BarcodeHeader(
                            barcode: $cvm.scanBarcode.barcode,
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
            /// Note:
            /// The `InputProductDetailView` itself does not contain `NavigationStack`
            /// therefore, it is the parent view's (this view) responsibility to
            /// embed `InputProductDetailView` to `NavigationStack` so that the
            /// navigation bar and large navigation title could display properly
            NavigationStack {
                InputProductDetailView(detail: cvm.detail)
            }
        }
        .alert(
            "Error",
            isPresented: Binding<Bool>(
                get: { cvm.scanBarcode.errorMessage != nil },
                set: { _ in cvm.scanBarcode.errorMessage = nil }
            )
        ) {
            Button(role: .cancel) {
                
            } label: {
                Text("OK")
            }
        } message: {
            Text(cvm.scanBarcode.errorMessage ?? "")
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
    
//    static func ==(lhs: DisplayedImageView, rhs: DisplayedImageView) -> Bool {
//        lhs.image == rhs.image &&
//        lhs.isScaleToFill == rhs.isScaleToFill &&
//        lhs.bboxes == rhs.bboxes &&
//        lhs.rescaledImageSize == rhs.rescaledImageSize &&
//        lhs.screenSize == rhs.screenSize &&
//        lhs.barcode == rhs.barcode &&
//        lhs.barcodeBBox == rhs.barcodeBBox
//    }
    let image: UIImage
    @Binding var isScaleToFill: Bool
//    let bboxes: [BoundingBox]
//    let rescaledImageSize: CGSize
    let screenSize: CGSize
    let barcode: String
    let normalizedBarcodeBBox: CGRect?
    let didSearchButtonCliced: (() -> Void)?
    let didAnalysisButtonCliced: (() -> Void)?
    let convertNormalizedBBoxToRectInSpecificView: (CGRect, CGSize, CGSize, ContentMode) -> CGRect
    let convertImage: (CGSize, CGSize, ContentMode) -> CGRect
    let transform: (CGRect, CGRect) -> CGRect
    
    @State private var isBarCodeIndicatorViewAppear: Bool = false
    
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
//        ZoomableScrollView(
//            image: image,
//            isScaleToFill: $isScaleToFill,
//            size: screenSize
//        )
//        .frame(width: screenSize.width, height: screenSize.height)
//        .overlay(alignment: .topLeading) {
//            if let bbox: CGRect = barcodeBBox {
//                BarCodeIndicatorView(
//                    barcode: barcode,
//                    width: bbox.width,
//                    height: bbox.height,
//                    offset: bbox.origin
//                )
//                .animation(.easeIn, value: barcodeBBox)
//            }
//        }
        ZoomableScrollView(
            isScaleToFill: $isScaleToFill,
            size: screenSize
        ) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: isScaleToFill ? .fill : .fit)
                .overlay(alignment: .topLeading) {
                    GeometryReader { (proxy: GeometryProxy) in
                        /// Note:
                        /// This `containerSize` will keep update its value when user pinch to zoom the image
                        /// in the scrollview, then the `rectOfImage` will be called and keep up-to-dated,
                        /// therefore it will result in the `BarCodeIndicatorView` well-positioned w.r.t.
                        /// user zooming direction and position
                        ///
                        /// Btw, this `containerSize` is not the same as screen size, because for example, when the
                        /// content mode is `scaleToFill`, there will be area in iamge overflowed outside the screen view,
                        /// so we need this `containerSize` to keep track of the entire image size (including the overflowed area)
                        let containerSize: CGSize = proxy.frame(in: .local).size
                        
                        if let normalizedBarcodeBBox {
                            let rectOfImage: CGRect = convertImage(image.size, containerSize, isScaleToFill ? .fill : .fit)
                            /// un-normalized bounding box, given the real image frame (which contains
                            /// the real image size to be scaled, and the position to be offseted) placed on container
                            let convertedRect: CGRect = transform(normalizedBarcodeBBox, rectOfImage)
                            BarCodeIndicatorView(
                                barcode: barcode,
                                width: convertedRect.width,
                                height: convertedRect.height,
                                offset: convertedRect.origin,
                                isAppeared: $isBarCodeIndicatorViewAppear
                            )
                        }
                    }
                }
                .frame(width: screenSize.width, height: screenSize.height)
        }
        .overlay(alignment: .top) {
            Header(
                barcode: barcode,
                didSearchButtonCliced: didSearchButtonCliced,
                didAnalysisButtonCliced: didAnalysisButtonCliced
            )
        }
        .onAppear {
            isBarCodeIndicatorViewAppear = true
        }
    }
    
    private func toBinding<T: View>(v: T) -> Binding<T> {
        Binding<T>(
            get: { v },
            set: { _ in }
        )
    }
    
    fileprivate struct Header: View {
        @Environment(\.safeAreaInsets) var safeArea
        let barcode: String
        let didSearchButtonCliced: (() -> Void)?
        let didAnalysisButtonCliced: (() -> Void)?
        var body: some View {
            VStack(spacing: 16) {
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
                if !barcode.isEmpty {
                    Rectangle()
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("Barcode: ")
                            .productFont(.bold, relativeTo: .body)
                            .foregroundStyle(.primary)
                        Text(barcode)
                            .productFont(.regular, relativeTo: .body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
