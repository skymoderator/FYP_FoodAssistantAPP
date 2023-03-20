//
//  CatagoryViewSearchSuggestion.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 20/3/2023.
//

import SwiftUI

extension CatagoryView {
    struct SearchSuggestion: View {
        @Namespace var ns
        @Binding var search: String
        let products: [Product]
        var body: some View {
            let results: [Product] = products
                .filter({ $0.name.lowercased().contains(search.lowercased()) })
            ForEach(results) { (product: Product) in
                ProductInformationRow(
                    ns: ns,
                    product: product,
                    color: .random,
                    onEnterInputView: { },
                    onBackFromInputView: { }
                )
            }
            if !search.isEmpty && !results.isEmpty {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 80)
            }
        }
    }
}
