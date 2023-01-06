//
//  CatagoryDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 3/1/2023.
//

import SwiftUI

struct CatagoryDetailView: View {
    @ObservedObject var cvm: CatagoryViewModel
    @StateObject var cdvm: CatagoryDetailViewModel
    @Namespace var namespace
    let catagory: String
    let products: [Product]
    let color: Color
    
    init(
        cvm: CatagoryViewModel,
        catagory: String,
        products: [Product],
        color: Color
    ) {
        self._cvm = ObservedObject(wrappedValue: cvm)
        self._cdvm = StateObject(wrappedValue: CatagoryDetailViewModel(products: products))
        self.catagory = catagory
        self.products = products
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { (proxy: GeometryProxy) in
                let size: CGSize = proxy.size
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
                        ForEach(cdvm.characters) {
                            (pc: CatagoryDetailViewModel.ProductCharacter) in
                            AlphabetSession(cdvm: cdvm, ns: namespace, pc: pc, color: color)
                        }
                    }
                    .offset(space: "scroller") { (rect: CGRect) in
                        // MARK: Whenever Scrolling Does
                        // Resetting Timeout
                        if cdvm.hideIndicatorLabel && rect.minY < 0 {
                            cdvm.scrollerTimeOut = 0
                            cdvm.hideIndicatorLabel = false
                        }
                        
                        let rectHeight: CGFloat = rect.height
                        let viewHeight: CGFloat = size.height + cdvm.startOffset
                        
                        cdvm.scrollerHeight = (viewHeight/rectHeight)*viewHeight
                        
                        // MARK: Finding Scroll Indicator Offset
                        let progress = rect.minY / (rectHeight - size.height)
                        // MARK: Simply Multiply With View Height
                        // Eliminating Scroller Height
                        cdvm.indicatorOffset = -progress * (size.height - cdvm.scrollerHeight)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Scroller(cdvm: cdvm, color: color)
                }
                .coordinateSpace(name: "scroller")
            }
            .navigationTitle(catagory)
            .productLargeNavigationBar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavTrailingButton()
                }
            }
            .nativeSearchBar(text: cdvm.searchedProduct, placeHolder: "Search Product")
            .offset(space: "scroller") { (rect: CGRect) in
                if cdvm.startOffset != rect.minY {
                    cdvm.startOffset = rect.minY
                }
            }
            .onReceive(
                Timer
                    .publish(
                        every: 0.01,
                        on: .main,
                        in: .default
                    )
                    .autoconnect()
            ) { _ in
                if cdvm.scrollerTimeOut < 0.3 {
                    cdvm.scrollerTimeOut += 0.01
                } else {
                    // MARK: Scrolling is Finished
                    // It Will Fire Many Times So Use Some Conditions Here
                    if !cdvm.hideIndicatorLabel {
                        // Scrolling is Finished
                        cdvm.hideIndicatorLabel = true
                    }
                }
            }
            Rectangle()
                .frame(height: screenHeight/8)
                .opacity(0)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

fileprivate struct Scroller: View {
    @ObservedObject var cdvm: CatagoryDetailViewModel
    let color: Color
    
    var currentC: CatagoryDetailViewModel.ProductCharacter? {
        cdvm.currentCharacter
    }
    
    var shouldDisappear: Bool {
        cdvm.hideIndicatorLabel || currentC == nil
    }
    
    var body: some View {
        HStack {
            HStack {
                Text(currentC?.value ?? "")
                    .productFont(.bold, relativeTo: .body)
                    .foregroundColor(.primary)
                Text("\(currentC?.products.count ?? 0) items")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .padding(.trailing, 4)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .padding(.trailing)
            .offset(x: shouldDisappear ? 200 : 0)
            .environment(\.colorScheme, .dark)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color)
                .frame(width: 2, height: cdvm.scrollerHeight)
        }
        .padding(.trailing, 5)
        .offset(y: cdvm.indicatorOffset)
        .animation(
            .interactiveSpring(
                response: 0.5,
                dampingFraction: 0.6,
                blendDuration: 0.6),
            value: shouldDisappear
        )
    }
}

fileprivate struct NavTrailingButton: View {
    @EnvironmentObject var mvm: MainViewModel
    var body: some View {
        Menu {
            Menu {
                Button {
                    
                } label: {
                    Label("Name", systemImage: "abc")
                }
                Button {
                    
                } label: {
                    Label("Price", systemImage: "dollarsign")
                }
            } label: {
                Label("Sort By", systemImage: "arrow.up.arrow.down")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

fileprivate struct TinyDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundColor(.secondary)
    }
}

fileprivate struct AlphabetSession: View {
    @ObservedObject var cdvm: CatagoryDetailViewModel
    let ns: Namespace.ID
    let pc: CatagoryDetailViewModel.ProductCharacter
    let color: Color
    var body: some View {
        VStack(alignment: .leading) {
            Text(pc.value)
                .foregroundColor(.primary)
                .productFont(.bold, relativeTo: .title2)
                .padding(.leading, 24)
            TinyDivider()
            ForEach(
                cdvm.searchedProduct.wrappedValue.isEmpty ? pc.products : pc.products.filter { $0.name.contains(cdvm.searchedProduct.wrappedValue) }
            ) { (p: Product) in
                Row(ns: ns, product: p, color: color)
                    .padding(.horizontal)
            }
            TinyDivider()
        }
        .offset(space: "scroller") { (rect: CGRect) in
            // MARK: Verifying Which section is at the Top (Near NavBar)
            // Updating Character Rect When ever it's Updated
            if cdvm.characters.indices.contains(pc.index){
                cdvm.characters[pc.index].rect = rect
            }
            
            // Since Every Character moves up and goes beyond Zero (It will be like A,B,C,D)
            // So We're taking the last character
            if let last: CatagoryDetailViewModel.ProductCharacter =
                cdvm.characters.last(where: {
                    (char: CatagoryDetailViewModel.ProductCharacter) in
                    char.rect.minY < 0
                }), last.uuid != (cdvm.currentCharacter?.uuid ?? "") {
                cdvm.currentCharacter = last
            }
        }
    }
}

fileprivate struct Row: View {
    @Environment(\.colorScheme) var scheme
    let ns: Namespace.ID
    let product: Product
    let color: Color
    
    var destination: some View {
        InputProductDetailView(product: product)
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "fork.knife.circle")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(color)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(product.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .productFont(.bold, relativeTo: .title3)
                    HStack {
                        Image(systemName: "barcode")
                            .foregroundColor(.secondary)
                        Text("Barcode: \(product.barcode)")
                            .foregroundColor(.secondary)
                            .productFont(.regular, relativeTo: .body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(
                    product.product_price.first?.price == nil ?
                    "NA" : "$\(product.product_price.first!.price.formatted())"
                )
                .foregroundColor(.primary)
                .productFont(.bold, relativeTo: .body)
                .padding(8)
                .background(.secondary.opacity(scheme == .dark ? 0.4 : 0.2))
                .clipShape(Capsule())
            }
        }
        .matchedGeometryEffect(id: "\(product.barcode)\(product.name)", in: ns)
        .previewContextMenu(
            destination: destination,
            presentAsSheet: false
        )
    }
}

struct CatagoryDetailView_Previews: PreviewProvider {
    @StateObject static var cvm = CatagoryViewModel()
    static let catagory: String = "Beer / Wines / Spirits"
    static var previews: some View {
        NavigationStack {
            CatagoryDetailView(
                cvm: cvm,
                catagory: catagory,
                products: cvm.foodsService.productWhoweCategory(number: 1, is: catagory),
                color: .random
            )
        }
    }
}
