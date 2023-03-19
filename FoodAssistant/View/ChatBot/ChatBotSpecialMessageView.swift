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
        if intent == .productPrice {
            ChatBotProductPriceCell(message: message, viewWidth: viewWidth)
        } else if intent == .findSimilarProduct {
            ChatBotFindSimilarProductCell(productsResponse: message.productsResponse)
        } else if intent == .productDetails {
            ChatBotProductDetailCell(ns: ns, products: message.productsResponse)
        }
    }
}
