//
//  ChatBotSupermarketCell.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 19/3/2023.
//

import SwiftUI

struct ChatBotSupermarketCell: View {
    @Environment(\.colorScheme) var scheme
    let supermarkets: [Supermarket]
    let products: [Product]
    let viewWidth: CGFloat
        
    init(products: [Product], viewWidth: CGFloat) {
        self.products = products
        self.supermarkets = Array(Set(products.flatMap(\.prices).map(\.supermarket))).sorted(by: \.rawValue)
        self.viewWidth = viewWidth
    }
    
    var body: some View {
        let numRow: CGFloat = supermarkets.count > 1 ? 2 : 1
        let rowSpacing: CGFloat = 12
        let rowHeight: CGFloat = 100
        let totalHeight: CGFloat = numRow == 1 ? rowHeight : rowHeight*2 + rowSpacing
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(
                rows: Array(repeating: GridItem(.fixed(rowHeight), spacing: rowSpacing), count: 2),
                spacing: rowSpacing
            ) {
                ForEach(supermarkets, id: \.rawValue) { (sm: Supermarket) in
                    let productsAtThatSM: [Product] = products.filter({ $0.prices.contains(where: { $0.supermarket == sm }) })
                    SuperMarketCell(products: productsAtThatSM, sm: sm)
                        .padding(20)
                        .frame(width: max(0, viewWidth - 48), height: rowHeight, alignment: .leading)
                        .background(Color.black.brightness(scheme == .light ? 0.95 : 0.2))
                        .cornerRadius(20, style: .continuous)
                        .previewContextMenu(
                            destination: ChatBotProductList(products: productsAtThatSM),
                            preview: ChatBotProductList(products: productsAtThatSM),
                            navigationValue: products
                        )
                }
            }
            .padding(.horizontal)
        }
        .frame(height: totalHeight)
    }
}

fileprivate struct SuperMarketCell: View {
    let products: [Product]
    let sm: Supermarket
    var body: some View {
        let count: Int = products.count
        let smName: String = sm.rawValue
        HStack {
            VStack(alignment: .leading) {
                Text(smName)
                    .productFont(.bold, relativeTo: .title3)
                    .foregroundColor(.primary)
                Text("\(count) product\(count > 1 ? "s" : "")")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: -8) {
                let num: Int = min(6, products.count)
                ForEach(0..<num, id: \.self) { (index: Int) in
                    let product: Product = products[index]
                    ProductIcon(name: product.name)
                        .zIndex(Double(num - index))
                }
            }
        }
    }
}

fileprivate struct ProductIcon: View {
    let name: String
    var body: some View {
        Text(String(name.prefix(1)))
            .foregroundColor(.primary)
            .productFont(.bold, relativeTo: .body)
            .padding(8)
            .background(.random)
            .clipShape(Circle())
            .shadow(radius: 10)
    }
}

struct ChatBotSupermarketCell_Previews: PreviewProvider {
    static var previews: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let width: CGFloat = proxy.size.width
//            let height: CGFloat = proxy.size.height
//            ChatBotSupermarketCell(products: dummyMessages[0].productsResponse, viewWidth: width)
//                .frame(height: height, alignment: .center)
//        }
//        .frame(maxHeight: .infinity, alignment: .center)
//        .preferredColorScheme(.dark)
        ChatBotView()
    }
}
