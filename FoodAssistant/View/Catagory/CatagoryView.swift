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
            List {
                Section {
                    ForEach(cvm.filteredCats, id: \.self) { (cat: Catagory) in
                        CatagoryRow(category: cat, ns: ns)
                    }
                } footer: {
                    Rectangle()
                        .frame(height: screenHeight/8)
                        .opacity(0)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("Catagory")
            .nativeSearchBar(
                text: cvm.searchedCatagory,
                placeHolder: "Search Catagory"
            )
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

fileprivate struct CatagoryRow: View {
    let category: Catagory
    let ns: Namespace.ID
    var body: some View {
        NavigationLink {
            CatagoryDetailView(catagory: category)
        } label: {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.random)
                Text("\(category.rawValue)")
                    .productFont(.regular, relativeTo: .body)
                Spacer()
                Text("15 items")
                    .foregroundColor(.secondary)
                    .productFont(.regular, relativeTo: .callout)
            }
            .matchedGeometryEffect(id: category.rawValue, in: ns)
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
