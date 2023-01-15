//
//  ProductView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI
import Introspect

struct CatagoryView: View {
    
    @EnvironmentObject var mvm: MainViewModel
    @StateObject var cvm = CatagoryViewModel()
    @Namespace var ns
    let screenSize: CGSize
    
    var body: some View {
        NavigationStack(path: $cvm.navigationPath) {
            ZStack {
                if cvm.foodsService.isLoading {
                    LoadingView()
                } else {
                    if cvm.viewType == .list {
                        ListView(
                            filteredCats: cvm.filteredCats,
                            products: cvm.catProductsDict,
                            colors: cvm.colors,
                            ns: ns,
                            screenHeight: screenSize.height
                        )
                    } else {
                        GalleryView(
                            ns: ns,
                            filteredCats: cvm.filteredCats,
                            products: cvm.catProductsDict,
                            colors: cvm.colors,
                            screenHeight: screenSize.height
                        )
                    }
                }
            }
            .navigationTitle("Catagory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    MenuView(menuItem: cvm.toolBarItem)
                }
            }
            .nativeSearchBar(
                text: cvm.searchedCatagory,
                placeHolder: "Search Catagory",
                backgroundColor: .systemGroupedBackground
            )
            .navigationDestination(for: CatagoryViewModel.NavigationRoute.self) {
                (detail: CatagoryViewModel.NavigationRoute) in
                switch detail {
                case .scanBarCodeView:
                    ScanBarcodeView(mvm: mvm, path: $cvm.navigationPath)
                case .categoryDetailView(let categoryDetail):
                    CatagoryDetailView(detail: categoryDetail, screenHeight: screenSize.height)
                case .inputProductDetailView(let product):
                    InputProductDetailView(product: product)
                }
                
            }
        }
        .productLargeNavigationBar()
        .frame(width: screenSize.width, height: screenSize.height)
    }
}

fileprivate struct ErrorView: View {
    let message: String
    let ns: Namespace.ID
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error Inspection")
                .foregroundColor(.white)
                .productFont(.bold, relativeTo: .title)
                .matchedGeometryEffect(id: "error-title", in: ns)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .matchedGeometryEffect(id: "error-icon", in: ns)
                        .foregroundColor(.white)
                        .padding(4)
                }
            Text(message)
                .foregroundColor(.white)
                .productFont(.regular, relativeTo: .body)
                .matchedGeometryEffect(id: "error-context", in: ns)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            Button {
                
            } label: {
                Text("Reload Now")
                    .foregroundColor(.systemOrange)
                    .productFont(.bold, relativeTo: .title2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(.white)
                    .cornerRadius(10, style: .continuous)
                    .shadow(color: Color.primary.opacity(0.2), radius: 10)
            }
            .matchedGeometryEffect(id: "error-button", in: ns)
        }
        .padding(24)
        .background(.systemOrange)
        .cornerRadius(20, style: .continuous)
        .matchedGeometryEffect(id: "error-background", in: ns)
        .listRowBackground(EmptyView())
        .listRowInsets(.zero)
    }
}

fileprivate struct ListView: View {
    let filteredCats: [String]
    let products: [String : [Product]]
    let colors: [String : Color]
    let ns: Namespace.ID
    let screenHeight: CGFloat
    
    var body: some View {
        List {
            Section {
                ForEach(filteredCats, id: \.self) { (cat: String) in
                    CatagoryListRow(
                        category: cat,
                        ns: ns,
                        products: products[cat] ?? [],
                        color: colors[cat] ?? .black,
                        screenHeight: screenHeight
                    )
                }
            } footer: {
                Rectangle()
                    .frame(height: screenHeight/8)
                    .opacity(0)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    fileprivate struct CatagoryListRow: View {
        let category: String
        let ns: Namespace.ID
        let products: [Product]
        let color: Color
        let screenHeight: CGFloat
        
        @ViewBuilder
        func destination(isPreview: Bool) -> some View {
            CatagoryDetailView(
                detail: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: isPreview
                ),
                screenHeight: screenHeight
            )
        }
        
        var body: some View {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(color)
                    .matchedGeometryEffect(id: "\(category)-icon", in: ns)
                Text("\(category)")
                    .productFont(.regular, relativeTo: .body)
                    .matchedGeometryEffect(id: "\(category)-catName", in: ns)
                Spacer()
                Text("\(products.count) items")
                    .foregroundColor(.secondary)
                    .productFont(.regular, relativeTo: .callout)
                    .matchedGeometryEffect(id: "\(category)-itemsNum", in: ns)
            }
            .matchedGeometryEffect(id: "\(category)-row", in: ns)
            .previewContextMenu(
                destination: destination(isPreview: false),
                preview: destination(isPreview: true),
                navigationValue: CatagoryViewModel
                    .NavigationRoute
                    .categoryDetailView(
                        CatagoryDetailView.CategoryDetail(
                            category: category,
                            products: products,
                            color: color,
                            isPreview: false
                        )
                    )
            )
        }
    }
}

fileprivate struct GalleryView: View {
    var ns: Namespace.ID
    let filteredCats: [String]
    let products: [String : [Product]]
    let colors: [String : Color]
    let screenHeight: CGFloat
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(100))],
                spacing: 16) {
                    ForEach(filteredCats, id: \.self) { (cat: String) in
                        CatagoryGalleryBlock(
                            category: cat,
                            ns: ns,
                            products: products[cat] ?? [],
                            color: colors[cat] ?? .black,
                            screenHeight: screenHeight
                        )
                    }
                }
                .padding(.bottom, screenHeight/8)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    fileprivate struct CatagoryGalleryBlock: View {
        let category: String
        let ns: Namespace.ID
        let products: [Product]
        let color: Color
        let screenHeight: CGFloat
        
        @ViewBuilder
        func destination(isPreview: Bool) -> some View {
            CatagoryDetailView(
                detail: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: isPreview
                ),
                screenHeight: screenHeight
            )
        }
        
        var body: some View {
            VStack {
                Rectangle()
                    .foregroundColor(color)
                    .frame(height: 75)
                    .matchedGeometryEffect(id: "\(category)-icon", in: ns)
                Text("\(category)")
                    .foregroundColor(.primary)
                    .productFont(.regular, relativeTo: .body)
                    .matchedGeometryEffect(id: "\(category)-catName", in: ns)
                Text("\(products.count) items")
                    .foregroundColor(.secondary)
                    .productFont(.regular, relativeTo: .callout)
                    .matchedGeometryEffect(id: "\(category)-itemsNum", in: ns)
                Spacer()
            }
            .matchedGeometryEffect(id: "\(category)-row", in: ns)
            .previewContextMenu(
                destination: destination(isPreview: false),
                preview: destination(isPreview: true),
                navigationValue: CatagoryViewModel
                    .NavigationRoute
                    .categoryDetailView(
                        CatagoryDetailView.CategoryDetail(
                            category: category,
                            products: products,
                            color: color,
                            isPreview: false
                        )
                    )
            )
        }
    }
}

fileprivate struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        ErrorView(message: """
//dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Error Domain=NSCocoaErrorDomain Code=3840 "Invalid value around line 1, column 0." UserInfo={NSDebugDescription=Invalid value around line 1, column 0., NSJSONSerializationErrorIndex=0})))
//""")
        CatagoryView(screenSize: mvm.screenSize)
//        ContentView()
            .environmentObject(mvm)
    }
}
