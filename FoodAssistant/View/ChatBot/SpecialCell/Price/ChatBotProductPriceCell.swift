//
//  ChatBotProductPriceCell.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/3/2023.
//

import Charts
import SwiftUI

struct ChatBotProductPriceCell: View {
    let message: ChatBotMessage
    let isSingleProduct: Bool
    let viewWidth: CGFloat
    
    init(message: ChatBotMessage, viewWidth: CGFloat) {
        self.message = message
        self.isSingleProduct = message.productsResponse.count == 1
        self.viewWidth = viewWidth
    }

    var body: some View {
        if isSingleProduct {
            ChatBotSingleProductCell(product: message.productsResponse.first!, viewWidth: viewWidth)
        } else {
            ChatBotPriceMultipleProductsCell(products: message.productsResponse, viewWidth: viewWidth)
        }
    }
}

struct ChatBotProductPriceCell_PreviewProvider: PreviewProvider {
    static var previews: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let width: CGFloat = proxy.size.width
            let height: CGFloat = proxy.size.height
            ChatBotProductPriceCell(message: dummyMessages[0], viewWidth: width)
                .frame(height: height, alignment: .center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding(.horizontal)
        .preferredColorScheme(.dark)
    }
}
