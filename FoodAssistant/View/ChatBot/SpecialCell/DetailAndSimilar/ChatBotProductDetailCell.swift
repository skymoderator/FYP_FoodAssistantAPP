//
//  ChatBotProductDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/3/2023.
//

import SwiftUI

struct ChatBotProductDetailCell: View {
    let products: [Product]
    let viewWidth: CGFloat
    var body: some View {
        let count: CGFloat = CGFloat(products.count)
        let rowWidth: CGFloat = max(0, viewWidth - 48)
        let padding: CGFloat = 16
        let totalWidth: CGFloat = rowWidth*count + padding*max(0, count-1)
        let height: CGFloat = 100
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: padding) {
                ForEach(products) { product in
                    ProductCell(
                        product: product,
                        color: .systemBlue,
                        width: rowWidth,
                        height: height
                    )
                }
            }
            .frame(width: totalWidth)
            .padding(.horizontal)
        }
        .frame(width: viewWidth, height: height)
//        .background(.random)
    }
}

fileprivate struct ProductCell: View {
    @Environment(\.colorScheme) var scheme
    let product: Product
    let color: Color
    let width: CGFloat
    let height: CGFloat
    
    var detail: InputProductDetailView.Detail {
        InputProductDetailView.Detail(product: product, editable: false)
    }
    
    var body: some View {
        NavigationLink(value: detail) {
            HStack(spacing: 16) {
                Image(systemName: "fork.knife.circle")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(color)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(product.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .productFont(.bold, relativeTo: .title3)
                    HStack(alignment: .top) {
                        Image(systemName: "barcode")
                            .foregroundColor(.secondary)
                        Text("Barcode: \(product.barcode)")
                            .foregroundColor(.secondary)
                            .productFont(.regular, relativeTo: .body)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(
                    product.prices.first?.price == nil ?
                    "NA" : "$\(product.prices.first!.price.formatted())"
                )
                .foregroundColor(.primary)
                .productFont(.bold, relativeTo: .body)
                .padding(8)
                .background(.secondary.opacity(scheme == .dark ? 0.4 : 0.2))
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .frame(width: width, height: height)
            .background(Color.black.brightness(scheme == .light ? 0.95 : 0.2))
            .cornerRadius(20, style: .continuous)
        }
        .previewContextMenu(
            destination: InputProductDetailView(detail: detail),
            preview: InputProductDetailView(detail: detail),
            navigationValue: detail,
            presentAsSheet: false
        )
    }
}

struct ChatBotProductDetailCell_Previews: PreviewProvider {
    static var previews: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let width: CGFloat = proxy.size.width
//            let height: CGFloat = proxy.size.height
//            ChatBotProductDetailCell(products: dummyMessages[0].productsResponse, viewWidth: width)
//                .frame(height: height, alignment: .center)
//        }
//        .frame(maxHeight: .infinity, alignment: .center)
//        .preferredColorScheme(.dark)
        ChatBotView()
    }
}
