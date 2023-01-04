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
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cvm.foodsService.isLoading {
                    LoadingView()
                } else {
                    ListView(cvm: cvm)
                }
            }
            .navigationTitle("Catagory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavTrailingButton()
                }
            }
        }
        .productLargeNavigationBar()
        .frame(width: screenWidth)
    }
}

fileprivate struct ListView: View {
    @ObservedObject var cvm: CatagoryViewModel
    @Namespace var ns
    
    var body: some View {
        List {
            Section {
                ForEach(cvm.filteredCats, id: \.self) { (cat: String) in
                    CatagoryRow(
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
                    .frame(height: screenHeight/8)
                    .opacity(0)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .nativeSearchBar(
            text: cvm.searchedCatagory,
            placeHolder: "Search Catagory"
        )

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

fileprivate struct CatagoryRow: View {
    @ObservedObject var cvm: CatagoryViewModel
    let category: String
    let ns: Namespace.ID
    let products: [Product]
    private let color: Color = .random
    var body: some View {
        NavigationLink {
            CatagoryDetailView(
                cvm: cvm,
                catagory: category,
                products: products,
                color: color
            )
        } label: {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(color)
                Text("\(category)")
                    .productFont(.regular, relativeTo: .body)
                Spacer()
                Text("\(products.count) items")
                    .foregroundColor(.secondary)
                    .productFont(.regular, relativeTo: .callout)
            }
            .matchedGeometryEffect(id: category, in: ns)
        }
    }
}

fileprivate struct NavTrailingButton: View {
    @EnvironmentObject var mvm: MainViewModel
    var body: some View {
        Menu {
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
        CatagoryView()
//        ContentView()
            .environmentObject(mvm)
    }
}
