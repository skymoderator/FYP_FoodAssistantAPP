//
//  AddProductView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 5/12/2022.
//

import SwiftUI

struct ScanBarcodeView: View {
    
    @ObservedObject var mvm: MainViewModel
    @Environment(\.safeAreaInsets) var safeArea
    @StateObject var vm: AddProductViewModel
    
    init(mvm: MainViewModel) {
        self._mvm = ObservedObject(wrappedValue: mvm)
        self._vm = StateObject(wrappedValue: AddProductViewModel(mvm: mvm))
    }
    
    var body: some View {
        ZStack {
            if mvm.isPortrait {
                VStack(spacing: 0) {
                    UpperView(vm: vm)
                    LowerView(vm: vm)
                }
            } else {
                HStack(spacing: 32) {
                    UpperView(vm: vm)
                    LowerView(vm: vm)
                }
            }
        }
        .padding(32)
        .frame(width: mvm.screenWidth, height: mvm.screenHeight)
        .background(.systemGroupedBackground)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: vm.scanBarcode.onAppear)
        .onDisappear(perform: vm.scanBarcode.onDisappear)
        .onTapGesture(perform: hideKeyboard)
        .toolbar {
            if !vm.product.barcode.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavBut(vm: vm)
                }
            }
        }
    }
}

fileprivate struct UpperView: View {
 
    @ObservedObject var vm: AddProductViewModel
    
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
                text: $vm.product.barcode,
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
    @EnvironmentObject var mvm: MainViewModel
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        VStack {
            Text("Point the camera to the product barcode")
                .multilineTextAlignment(.center)
                .productFont(.bold, relativeTo: .title3)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            CameraPreview(session: vm.cameraService.session)
                .overlay {
                    BarCodeIndicatorView(
                        barcode: vm.scanBarcode.barcode,
                        height: 100)
                }
                .cornerRadius(30)
        }
//        .padding(.bottom)
    }
}

fileprivate struct NavBut: View {
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        NavigationLink {
            InputProductDetailView(product: vm.product)
        } label: {
            Text("Next")
                .productFont(.bold, relativeTo: .body)
                .foregroundColor(.systemBlue)
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        NavigationStack {
//            ScanBarcodeView(mvm: mvm)
//        }
        ContentView()
            .environmentObject(mvm)
    }
}
