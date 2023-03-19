//
//  ChatBotSpecialMessageView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/3/2023.
//

import SwiftUI

struct ChatBotSpecialMessageView: View {
    let ns: Namespace.ID
    let message: ChatBotMessage
    let viewWidth: CGFloat
    
    var body: some View {
        let intent: IntentType = message.intentType ?? .undefined
        let products: [Product] = message.productsResponse
        if intent == .productPrice {
            ChatBotProductPriceCell(message: message, viewWidth: viewWidth)
        } else if intent == .findSimilarProduct {
            ChatBotFindSimilarProductCell(productsResponse: products)
        } else if intent == .productDetails {
            ChatBotProductDetailCell(products: products, viewWidth: viewWidth)
        } else if intent == .whereToBuyProduct {
            ChatBotSupermarketCell(products: products, viewWidth: viewWidth)
        }
    }
}
