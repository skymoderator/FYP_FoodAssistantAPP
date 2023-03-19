//
//  ChatBotProductDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/3/2023.
//

import SwiftUI

struct ChatBotProductDetailCell: View {
    let ns: Namespace.ID
    let products: [Product]
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            let width: CGFloat = size.width
            ScrollView(.horizontal) {
                HStack {
                    ForEach(products) { product in
                        ProductInformationRow(
                            ns: ns,
                            product: product,
                            color: .systemBlue,
                            onEnterInputView: { },
                            onBackFromInputView: { }
                        )
                        .frame(width: width)
                        .background(.random)
                    }
                }
            }
            .frame(width: width, height: 200)
            .background(.random)
        }
    }
    
}
