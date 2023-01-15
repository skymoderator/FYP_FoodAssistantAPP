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
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cvm.foodsService.isLoading {
                    LoadingView()
                } else {
                    if cvm.viewType == .list {
                        ListView(cvm: cvm, ns: ns)
                    } else {
                        GalleryView(cvm: cvm, ns: ns)
                    }
                }
            }
            .navigationTitle("Catagory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavTrailingButton(cvm: cvm)
                }
            }
            .nativeSearchBar(
                text: cvm.searchedCatagory,
                placeHolder: "Search Catagory",
                backgroundColor: .systemGroupedBackground
            )
            .navigationDestination(for: CatagoryDetailView.CategoryDetail.self) { (detail: CatagoryDetailView.CategoryDetail) in
                CatagoryDetailView(detail: detail, screenHeight: mvm.screenHeight)
            }
        }
        .productLargeNavigationBar()
        .frame(width: mvm.screenWidth, height: mvm.screenHeight)
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
    @EnvironmentObject var mvm: MainViewModel
    @ObservedObject var cvm: CatagoryViewModel
    var ns: Namespace.ID
    
    var body: some View {
        List {
            Section {
                ForEach(cvm.filteredCats, id: \.self) { (cat: String) in
                    CatagoryListRow(
                        cvm: cvm,
                        category: cat,
                        ns: ns,
                        products:
                            cvm
                            .foodsService
                            .productWhoweCategory(number: 1, is: cat)
                    )
                }
            } footer: {
                Rectangle()
                    .frame(height: mvm.screenHeight/8)
                    .opacity(0)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    fileprivate struct CatagoryListRow: View {
        @EnvironmentObject var mvm: MainViewModel
        @ObservedObject var cvm: CatagoryViewModel
        let category: String
        let ns: Namespace.ID
        let products: [Product]
        
        private var color: Color {
            cvm.colors[category] ?? .black
        }
        
        @ViewBuilder
        func destination(isPreview: Bool) -> some View {
            CatagoryDetailView(
                detail: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: isPreview
                ),
                screenHeight: mvm.screenHeight
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
                navigationValue: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: false
                )
            )
        }
    }
}

fileprivate struct GalleryView: View {
    @EnvironmentObject var mvm: MainViewModel
    @ObservedObject var cvm: CatagoryViewModel
    var ns: Namespace.ID
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(100))],
                spacing: 16) {
                    ForEach(cvm.filteredCats, id: \.self) { (cat: String) in
                        CatagoryGalleryBlock(
                            cvm: cvm,
                            category: cat,
                            ns: ns,
                            products:
                                cvm
                                .foodsService
                                .productWhoweCategory(number: 1, is: cat)
                        )
                    }
                }
                .padding(.bottom, mvm.screenHeight/8)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    fileprivate struct CatagoryGalleryBlock: View {
        @EnvironmentObject var mvm: MainViewModel
        @ObservedObject var cvm: CatagoryViewModel
        let category: String
        let ns: Namespace.ID
        let products: [Product]
        
        private var color: Color {
            cvm.colors[category] ?? .black
        }
        
        @ViewBuilder
        func destination(isPreview: Bool) -> some View {
            CatagoryDetailView(
                detail: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: isPreview
                ),
                screenHeight: mvm.screenHeight
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
                navigationValue: CatagoryDetailView.CategoryDetail(
                    category: category,
                    products: products,
                    color: color,
                    isPreview: false
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

fileprivate struct NavTrailingButton: View {
    @EnvironmentObject var mvm: MainViewModel
    @ObservedObject var cvm: CatagoryViewModel
    var body: some View {
        Menu {
            Button {
                withAnimation(.spring()) {
                    cvm.toggleViewType()
                }
            } label: {
                Label("View as \(cvm.viewType.label)", systemImage: cvm.viewType.systemName)
            }
            NavigationLink {
                ScanBarcodeView(mvm: mvm)
            } label: {
                Label("Add Product", systemImage: "plus")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        ErrorView(message: """
//dataCorrupted(Swift.DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: Optional(Error Domain=NSCocoaErrorDomain Code=3840 "Invalid value around line 1, column 0." UserInfo={NSDebugDescription=Invalid value around line 1, column 0., NSJSONSerializationErrorIndex=0})))
//""")
        CatagoryView()
//        ContentView()
            .environmentObject(mvm)
    }
}
