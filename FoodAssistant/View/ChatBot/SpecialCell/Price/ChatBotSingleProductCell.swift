//
//  ChatBotSingleProductCell.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/3/2023.
//

import SwiftUI
import Charts

struct ChatBotSingleProductCell: View {
    @Environment(\.colorScheme) var scheme
    let product: Product
    let supermarkets: [Supermarket]
    let viewWidth: CGFloat
    
    init(product: Product, viewWidth: CGFloat) {
        self.product = product
        self.supermarkets = Array(Set(product.prices.map(\.supermarket))).sorted(by: \.rawValue)
        self.viewWidth = viewWidth
    }
    
    var body: some View {
        let pricesGroupBySuperMarket: [[ProductPrice]] = supermarkets.map { (sm: Supermarket) -> [ProductPrice] in
            product.prices.filter { $0.supermarket == sm }
        }
        let maxHeight: Int = pricesGroupBySuperMarket
            .reduce(0) { (partialResult: Int, next: [ProductPrice]) -> Int in
                max(partialResult, next.count > 1 ? 400 : 200)
            }
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(supermarkets, id: \.self) { (sm: Supermarket) in
                    VStack(alignment: .leading) {
                        Text("\(sm.rawValue) Store")
                            .productFont(.bold, relativeTo: .body)
                            .foregroundColor(.secondary)
                        let pricesAtThatStore: [ProductPrice] = product.prices.filter { $0.supermarket == sm }
                        if pricesAtThatStore.count == 1 {
                            SingleDayCard(price: pricesAtThatStore[0])
                        } else if pricesAtThatStore.count <= 7 {
                            WeekDaysCard(prices: pricesAtThatStore)
                        } else {
                            ManyDaysCard(prices: pricesAtThatStore)
                        }
                    }
                    .padding(32)
                    .frame(width: max(0, viewWidth - 48), height: CGFloat(maxHeight))
                    .background(Color.black.brightness(scheme == .light ? 0.95 : 0.2))
                    .cornerRadius(20, style: .continuous)
                }
            }
            .padding(.horizontal)
        }
    }
}

fileprivate struct SingleDayCard: View {
    let price: ProductPrice
    var body: some View {
        VStack {
            Text("On \(price.date.formatted(.dateTime.day().month().year()))")
                .productFont(.bold, relativeTo: .title2)
                .foregroundColor(.primary)
            Text("$\(price.price.formatted())")
                .productFont(.bold, relativeTo: .largeTitle)
                .foregroundColor(.primary)
                .padding()
                .padding(.horizontal)
                .background(.systemBlue)
                .clipShape(Capsule())
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}

fileprivate struct WeekDaysCard: View {
    let prices: [ProductPrice]
    var body: some View {
        let firstDay: Date = prices.sorted(by: \.date).first!.date
        let lastDay: Date = prices.sorted(by: \.date).last!.date
        VStack(alignment: .leading, spacing: 16) {
            Text("\(firstDay.formatted(.dateTime.month().day())) - \(lastDay.formatted(.dateTime.month().day()))")
                .productFont(.bold, relativeTo: .title)
                .foregroundColor(.primary)
            ChatBotPriceStatistics(prices: prices)
                .padding(.bottom)
            Chart(prices) { (price: ProductPrice) in
                BarMark(
                    x: .value("price", price.price),
                    y: .value("Date", price.date.formatted(.dateTime.day().month()))
                )
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Price (HKD)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
//            .chartYAxisLabel(position: .top, spacing: 8) {
//                Text("Date")
//                    .productFont(.bold, relativeTo: .subheadline)
//                    .foregroundColor(.secondary)
//            }
            .chartYAxis {
                AxisMarks(preset: .extended) { (value: AxisValue) in
                    AxisGridLine()
                    AxisValueLabel {
                        let index: Int = value.index
                        let price: ProductPrice = prices[index]
                        Text("\(price.date.formatted(.dateTime.day().month()))")
                            .productFont(.regular, relativeTo: .footnote)
                    }
                }
            }
        }
    }
}

fileprivate struct ManyDaysCard: View {
    let prices: [ProductPrice]
    let curGradient = LinearGradient(
        gradient: Gradient (
            colors: [
                .systemBlue.opacity(0.5),
                .systemBlue.opacity(0.2),
                .systemBlue.opacity(0.05),
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )
    var body: some View {
        let firstDay: Date = prices.sorted(by: \.date).first!.date
        let lastDay: Date = prices.sorted(by: \.date).last!.date
        VStack(alignment: .leading, spacing: 16) {
            Text("\(firstDay.formatted(.dateTime.month().day())) - \(lastDay.formatted(.dateTime.month().day()))")
                .productFont(.bold, relativeTo: .title)
                .foregroundColor(.primary)
            ChatBotPriceStatistics(prices: prices)
                .padding(.bottom)
            Chart(prices) { (price: ProductPrice) in
                LineMark(
                    x: .value("Date", price.date),
                    y: .value("price", price.price)
                )
                .interpolationMethod(.catmullRom)
                .symbol() {
                    Circle()
                        .fill(.orange)
                        .frame(width: 10)
                }
                
                AreaMark(
                    x: .value("Date", price.date),
                    y: .value("price", price.price)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(curGradient)
                .symbol() {
                    Circle()
                        .fill(.orange)
                        .frame(width: 10)
                }
            }
            .chartXAxisLabel(position: .bottom, alignment: .center) {
                Text("Date (Day)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartYAxisLabel(position: .top, spacing: 8) {
                Text("Price (HKD)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartYAxis() {
                AxisMarks(position: .leading)
            }
            .chartXAxis() {
                AxisMarks(values: .stride(by: .weekOfYear)) {
                    (value: AxisValue) in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(
                            format: .dateTime.day().month()
                        )
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct ChatBotSingleProductCell_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let width: CGFloat = proxy.size.width
            let height: CGFloat = proxy.size.height
            ChatBotProductPriceCell(message: dummyMessages[0], viewWidth: width)
                .frame(height: height, alignment: .center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(.dark)
    }
}
