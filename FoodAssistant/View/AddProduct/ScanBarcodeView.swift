//
//  AddProductView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 5/12/2022.
//

import SwiftUI
import AVFoundation

struct ScanBarcodeView: View {
    
    @ObservedObject var mvm: MainViewModel
    @Environment(\.safeAreaInsets) var safeArea
    @StateObject var vm: AddProductViewModel
    @Binding var path: NavigationPath
    let screenSize: CGSize
    
    init(mvm: MainViewModel, path: Binding<NavigationPath>, screenSize: CGSize) {
        self._mvm = ObservedObject(wrappedValue: mvm)
        self._vm = StateObject(wrappedValue: AddProductViewModel(mvm: mvm))
        self._path = path
        self.screenSize = screenSize
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                let isPortrait: Bool = screenSize.width < screenSize.height
                if isPortrait {
                    VStack(spacing: 0) {
                        UpperView(barcode: $vm.scanBarcode.barcode)
                        LowerView(
                            session: vm.scanBarcode.cameraService.session,
                            barcode: vm.scanBarcode.barcode
                        )
                    }
                } else {
                    HStack(spacing: 32) {
                        UpperView(barcode: $vm.scanBarcode.barcode)
                        LowerView(
                            session: vm.scanBarcode.cameraService.session,
                            barcode: vm.scanBarcode.barcode
                        )
                    }
                }
            }
            .padding(32)
            .frame(width: screenSize.width, height: screenSize.height)
        }
        .background(.systemGroupedBackground)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: vm.onAppear)
        .onDisappear(perform: vm.scanBarcode.onDisappear)
        .onTapGesture(perform: hideKeyboard)
        .toolbar {
            if !vm.product.barcode.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavBut(path: $path, product: vm.product)
                }
            }
        }
    }
}

fileprivate struct UpperView: View {
    @Binding var barcode: String
    var body: some View {
        VStack {
            Image(systemName: "barcode.viewfinder")
                .resizable()
                .scaledToFit()
                .foregroundColor(.systemBlue)
                .frame(width: 100, height: 100)
            Text("Scan Barcode")
                .productFont(.bold, relativeTo: .largeTitle)
                .foregroundColor(.primary)
            ProductFontPlaceholderTextField(
                text: $barcode,
                placeholder: "Product Barcode (e.g 4891028714842)",
                keyboardType: .numberPad
            )
            .padding()
            .background(.adaptable(light: .white, dark: .systemGray3))
            .cornerRadius(10)
        }
        .frame(maxHeight: .infinity)
    }
}

fileprivate struct LowerView: View {
    let session: AVCaptureSession
    let barcode: String
    var body: some View {
        VStack {
            Text("Point the camera to the product barcode")
                .multilineTextAlignment(.center)
                .productFont(.bold, relativeTo: .title3)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            CameraPreview(session: session)
                .overlay {
                    BarCodeIndicatorView(
                        barcode: barcode,
                        height: 100)
                }
                .cornerRadius(30)
        }
    }
}

fileprivate struct NavBut: View {
    @Binding var path: NavigationPath
    let product: Product
    var body: some View {
        Button {
            path.append(
                CatagoryViewModel
                    .NavigationRoute
                    .inputProductDetailView(
                        InputProductDetailView.Detail(
                            product: product
                        )
                    )
            )
        } label: {
            Text("Next")
                .productFont(.bold, relativeTo: .body)
                .foregroundColor(.systemBlue)
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    @State static var path = NavigationPath()
    static var previews: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            NavigationStack(path: $path) {
                ScanBarcodeView(mvm: mvm, path: $path, screenSize: size)
            }
        }
        .environmentObject(mvm)
    }
}
