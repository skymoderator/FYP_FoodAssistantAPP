//
//  ProductDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/11/2022.
//

import SwiftUI

struct ProductDetailView: View {
    
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                Rectangle()
                    .frame(height: screenHeight/8)
                    .opacity(0)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
//        .navigationTitle("\(vm.catagory.rawValue)")
//        .productLargeNavigationBar()
//        .nativeSearchBar(text: vm.searchedProduct, placeHolder: "Search Product")
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProductDetailView()
        }
    }
}
