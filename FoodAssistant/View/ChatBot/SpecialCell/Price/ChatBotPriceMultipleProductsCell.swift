//
//  ChatBotPriceMultipleProductsCell.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/3/2023.
//

import SwiftUI
import Charts
import SwiftDate

struct ChatBotPriceMultipleProductsCell: View {
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(supermarkets, id: \.self) { (sm: Supermarket) in
                    VStack(alignment: .leading) {
                        Text("\(sm.rawValue) Store")
                            .productFont(.bold, relativeTo: .body)
                            .foregroundColor(.secondary)
                        let productsThatHaveOnlyOneDayPrice: [Product] = products.filter {
                            $0.prices.filter( { $0.supermarket == sm } ).count == 1
                        }
                        let productsThatHaveMoreThanOneDayPrices: [Product] = products.filter {
                            $0.prices.filter( { $0.supermarket == sm } ).count > 1
                        }
                        if !productsThatHaveOnlyOneDayPrice.isEmpty {
                            SingleDayCard(products: productsThatHaveOnlyOneDayPrice, sm: sm)
                        } else if !productsThatHaveMoreThanOneDayPrices.isEmpty {
                            MultiDaysCard(products: productsThatHaveMoreThanOneDayPrices, sm: sm)
                        }
                    }
                    .padding(32)
                    .frame(width: max(0, viewWidth - 48), height: 400)
                    .background(Color.black.brightness(scheme == .light ? 0.95 : 0.2))
                    .cornerRadius(20, style: .continuous)
                }
            }
            .padding(.horizontal)
        }
    }
}

fileprivate struct MultiDaysCard: View {
    let products: [Product]
    let sm: Supermarket
    var body: some View {
        let prices: [ProductPrice] = products.flatMap(\.prices).filter { $0.supermarket == sm }
        let sortedDates: [Date] = prices.compactMap({ $0.date }).sorted(by: \.date)
        let firstDay: Date = sortedDates.first!.date
        let lastDay: Date = sortedDates.last!.date
        let colorLegends: [String : Color] = Dictionary(uniqueKeysWithValues:
            products.map { (product: Product) -> (String, Color) in
                (product.id.description, .random)
            })
        VStack(alignment: .leading, spacing: 8) {
            Text("\(firstDay.formatted(.dateTime.month().day())) - \(lastDay.formatted(.dateTime.month().day()))")
                .productFont(.bold, relativeTo: .title)
                .foregroundColor(.primary)
            ChatBotPriceStatistics(prices: prices)
            Chart(products) { (product: Product) in
                ForEach(product.prices.filter( { $0.supermarket == sm } )) { (price: ProductPrice) in
                    LineMark(
                        x: .value("Date", price.date),
                        y: .value("price", price.price)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol(by: .value("product", product.name))
                    .foregroundStyle(by: .value("product", product.id.description))
                }
            }
            .chatBotPriceChartSeeMore(products: products, colorLegends: colorLegends)
            .chartYAxisLabel(position: .top, spacing: 8) {
                Text("Price (HKD)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartYAxis() {
                AxisMarks(position: .leading)
            }
            .chartXAxis() {
                let duration: Int = lastDay.weekOfYear - firstDay.weekOfYear
                let lessThanAWeek: Bool = duration < 1
                let lessThanAMonth: Bool = duration <= 4
                AxisMarks(
                    values: .stride(by: lessThanAWeek ? .day : (lessThanAMonth ? .weekOfYear : .month))
                ) { (value: AxisValue) in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        format: lessThanAWeek ? .dateTime.day() : (lessThanAMonth ? .dateTime.day().month() : .dateTime.month())
                    )
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

fileprivate struct SingleDayCard: View {
    let products: [Product]
    let sm: Supermarket
    var body: some View {
        let prices: [ProductPrice] = products.flatMap(\.prices).filter { $0.supermarket == sm }
        let sortedDates: [Date] = prices.compactMap({ $0.date }).sorted(by: \.date)
        let firstDay: Date = sortedDates.first!.date
        let lastDay: Date = sortedDates.last!.date
        let colorLegends: [String : Color] = Dictionary(uniqueKeysWithValues:
            products.map { (product: Product) -> (String, Color) in
                (product.id.description, .random)
            })
        if firstDay.compare(toDate: lastDay, granularity: .day).rawValue == 0 {
            /// - Note: Same Day
            if prices.count == 1 {
                SingleSameDaySingleProductCard(product: products.first!)
            } else {
                SingleSameDayMultiProductsCard(
                    products: products,
                    sm: sm,
                    prices: prices,
                    colorLegends: colorLegends
                )
            }
        } else {
            SingleDifferentDayCard(
                products: products,
                sm: sm,
                prices: prices,
                colorLegends: colorLegends,
                firstDay: firstDay,
                lastDay: lastDay
            )
        }
    }
}

fileprivate struct SingleDifferentDayCard: View {
    let products: [Product]
    let sm: Supermarket
    let prices: [ProductPrice]
    let colorLegends: [String : Color]
    let firstDay: Date
    let lastDay: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(firstDay.formatted(.dateTime.month().day())) - \(lastDay.formatted(.dateTime.month().day()))")
                .productFont(.bold, relativeTo: .title)
                .foregroundColor(.primary)
            ChatBotPriceStatistics(prices: prices)
            Chart {
                ForEach(products) { (product: Product) in
                    ForEach(product.prices.filter( { $0.supermarket == sm} )) { (price: ProductPrice) in
                        BarMark(
                            x: .value("date", price.date, unit: .day),
                            y: .value("price", price.price)
                        )
                        .foregroundStyle(by: .value("product", product.id.description))
                        .position(by: .value("product", product.id.description))
                    }
                }
            }
            .chatBotPriceChartSeeMore(products: products, colorLegends: colorLegends)
            .chartYAxisLabel(position: .top, spacing: 8) {
                Text("Price (HKD)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 4) {
                Text("Date (MM/dd)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { (value: AxisValue) in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(
                        centered: true
                    )
                }
            }
        }
    }
}

fileprivate struct SingleSameDayMultiProductsCard: View {
    let products: [Product]
    let sm: Supermarket
    let prices: [ProductPrice]
    let colorLegends: [String : Color]
    var body: some View {
        let day: Date = prices.sorted(by: \.date).first!.date
        VStack(alignment: .leading, spacing: 8) {
            Text("\(day.formatted(.dateTime.month().day().year()))")
                .productFont(.bold, relativeTo: .title)
                .foregroundColor(.primary)
            ChatBotPriceStatistics(prices: prices)
            Chart {
                ForEach(products) { (product: Product) in
                    ForEach(product.prices.filter( { $0.supermarket == sm} )) { (price: ProductPrice) in
                        BarMark(
                            x: .value("name", product.name),
                            y: .value("price", price.price)
                        )
                        .foregroundStyle(by: .value("product", product.id.description))
                    }
                }
            }
            .chatBotPriceChartSeeMore(products: products, colorLegends: colorLegends)
            .chartYAxisLabel(position: .top, spacing: 8) {
                Text("Price (HKD)")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 4) {
                Text("Product")
                    .productFont(.regular, relativeTo: .subheadline)
                    .foregroundColor(.secondary)
            }
            .chartYAxis() {
                AxisMarks(position: .leading)
            }
            .chartXAxis(.hidden)
        }
    }
}

fileprivate struct SingleSameDaySingleProductCard: View {
    let product: Product
    var body: some View {
        VStack {
            let price: ProductPrice = product.prices.first!
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            Text("\(product.name)")
                .productFont(.bold, relativeTo: .title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
}

struct ChatBotPriceMultipleProductsCell_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let width: CGFloat = proxy.size.width
            let height: CGFloat = proxy.size.height
            ChatBotProductPriceCell(message: dummyMessages[0], viewWidth: width)
                .frame(height: height, alignment: .center)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .preferredColorScheme(.light)
    }
}
