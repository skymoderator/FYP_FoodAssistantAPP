//
//  ChatBotFindSimilarProductCell.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/3/2023.
//

import SwiftUI

struct ChatBotFindSimilarProductCell: View {
    let productsResponse: [Product]
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(productsResponse) { (product: Product) in
                Text("\(product.name) $\(product.prices.first?.price ?? 0.0)")
            }
        }

    }
}
