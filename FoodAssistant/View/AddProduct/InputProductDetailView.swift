//
//  InputProductDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/12/2022.
//

import SwiftUI
import Popovers
import Introspect
import Charts
import SwiftDate

struct InputProductDetailView: View {
    
    struct Detail: Hashable {
        static func == (lhs: InputProductDetailView.Detail, rhs: InputProductDetailView.Detail) -> Bool {
            lhs.product == rhs.product
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(product)
        }
        let product: Product
        let onAppear: (() -> Void)?
        let onDisappear: (() -> Void)?
        
        init(
            product: Product,
            onAppear: (() -> Void)? = nil,
            onDisappear: (() -> Void)? = nil
        ) {
            self.product = product
            self.onAppear = onAppear
            self.onDisappear = onDisappear
        }
    }
    
    
    @StateObject var vm: InputProductDetailViewModel
    let onAppear: (() -> Void)?
    let onDisappear: (() -> Void)?
    
    init(detail: Detail) {
        self._vm = StateObject(
            wrappedValue: InputProductDetailViewModel(product: detail.product)
        )
        self.onAppear = detail.onAppear
        self.onDisappear = detail.onDisappear
    }
    
    var body: some View {
        List {
            NameSession(product: $vm.product)
            InfoSession(product: vm.product)
            if let nutInfo: NutritionInformation = vm.product.nutrition {
                NutTableSession(nut: nutInfo)
            } else {
                MissingNutTabSession(
                    onTap: vm.onScanNutTableButTap
                )
            }
        }
        .navigationTitle("Product Detail")
        .productLargeNavigationBar()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
}

fileprivate struct NameSession: View {
    @Binding var product: Product
    var body: some View {
        Section {
            ProductFontPlaceholderTextField(
                text: $product.name,
                placeholder: "Product Name (e.g Coca Cola)"
            )
        } header: {
            Text("Name")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct InfoSession: View {
    let product: Product
    @State var showPopover = false
    @State var priceText = ""
    var body: some View {
        Section {
            PriceRow(
                product: product,
                showPopover: $showPopover
            )
            Row(
                image: "hammer.circle",
                color: .systemOrange,
                leading: "Manufacturer",
                trailig: product.manufacturer ?? "Unknown"
            )
            Row(
                image: "bag.circle",
                color: .systemBlue,
                leading: "Brand",
                trailig: product.brand ?? "Unknown"
            )
//            Row(
//                image: "cart.circle",
//                color: .systemGreen,
//                leading: "Supermarket",
//                trailig: vm.product.supermarket?.rawValue ?? "Unknown"
//            )
        } header: {
            Text("Information")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
    
    private struct PricePopoverBut: View {
        let product: Product
        @Binding var show: Bool
        var body: some View {
            Button {
                show.toggle()
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis.circle")
                    .foregroundColor(.systemBlue)
            }
            .buttonStyle(.plain)
            .popover(
                present: $show,
                attributes: { (a: inout Popover.Attributes) in
                    a.position = .absolute(
                        originAnchor: .bottom,
                        popoverAnchor: .top
                    )
                    a.rubberBandingMode = .none
                    a.sourceFrameInset.bottom = -32
                }
            ) {
                PricePopover(product: product)
            }
        }
    }
    
    private struct Row: View {
        let image: String
        let color: Color
        let leading: String
        let trailig: String
        var body: some View {
            HStack {
                Image(systemName: image)
                    .foregroundColor(color)
                Text(leading)
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                Spacer()
                Text(trailig)
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private struct PriceRow: View {
        let product: Product
        @Binding var showPopover: Bool
        var body: some View {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.red)
                Text("Price")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                Spacer()
                PricePopoverBut(product: product, show: $showPopover)
                Text("HKD $\(product.product_price.first?.price.formatted() ?? "NA")")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

fileprivate struct PricePopover: View {
    let product: Product
    let datas: [(Date, Double)]
    let minPrice: Double
    let maxPrice: Double
    let avgPrice: Double
    init(product: Product) {
        self.product = product
        let dates: [Date] = product.product_price.map { $0.date }
        let prices: [Double] = product.product_price.map { $0.price }
        datas = zip(dates, prices).map { ($0, $1) }
        minPrice = product.product_price.map(\.price).min() ?? 0
        maxPrice = product.product_price.map(\.price).max() ?? 0
        avgPrice = product.product_price.map(\.price).reduce(0.0, +)/Double(product.product_price.count)
    }
    var body: some View {
        Templates.Container(
            arrowSide: .top(.centered),
            cornerRadius: 20,
            backgroundColor: .systemGroupedBackground,
            padding: 0
        ) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Price Trend")
                        .foregroundColor(.primary)
                        .productFont(.bold, relativeTo: .title2)
                    Text("Source: Centre for Food Safety. [Learn More](https://data.gov.hk/en-data/dataset/cc-pricewatch-pricewatch)")
                        .foregroundColor(.secondary)
                        .productFont(.regular, relativeTo: .body)
                    Chart(datas, id: \.0) { (data: (Date, Double)) in
                        LineMark(
                            x: .value("Date", data.0),
                            y: .value("Price", data.1)
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartYAxisLabel(position: .leading, alignment: .center) {
                        Text("Price ($)")
                            .productFont(.bold, relativeTo: .caption)
                            .foregroundColor(.secondary)
                    }
                    .chartXAxisLabel(position: .bottom, alignment: .center) {
                        Text("Date (DD/MM)")
                            .productFont(.bold, relativeTo: .caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 200)
                    .padding(.vertical, 8)
                    VStack(spacing: 0) {
                        Row(
                            image: "distribute.vertical.top",
                            color: .systemRed,
                            leading: "Lowest:",
                            trailing: "HKD $\(minPrice)"
                        )
                        Divider()
                        Row(
                            image: "distribute.vertical.bottom",
                            color: .systemOrange,
                            leading: "Highest:",
                            trailing: "HKD $\(maxPrice)"
                        )
                        Divider()
                        Row(
                            image: "distribute.vertical.center",
                            color: .systemBlue,
                            leading: "Average:",
                            trailing: "HKD $\(avgPrice.formatted())"
                        )
                    }
                    .background(.adaptable(light: .white, dark: .systemGray6))
                    .cornerRadius(10, style: .continuous)
                }
                .padding()
            }
            .frame(height: 400)
            .frame(maxWidth: 400)
        }
    }
    
    private struct Row: View {
        let image: String
        let color: Color
        let leading: String
        let trailing: String
        var body: some View {
            HStack {
                Image(systemName: image)
                    .foregroundColor(color)
                Text(leading)
                    .foregroundColor(.primary)
                Spacer()
                Text(trailing)
                    .foregroundColor(.secondary)
            }
            .productFont(.regular, relativeTo: .body)
            .padding()
        }
    }
}

fileprivate struct MissingNutTabSession: View {
    private let title: String = "Missing Nutrition Information"
    private let subtitle: String = "Help others get to know more about this product by scanning the nutrition table on the product package"
    let onTap: () -> Void
    var body: some View {
        Section {
            VStack(alignment: .center) {
                Image(systemName: "tablecells.badge.ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text(title)
                    .productFont(.bold, relativeTo: .title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .productFont(.regular, relativeTo: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                Button(action: onTap) {
                    HStack {
                        Image(systemName: "plus.viewfinder")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        Text("Scan Nutrition Table")
                            .productFont(.bold, relativeTo: .body)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(.systemBlue)
                    .clipShape(Capsule())
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .overlay {
                GeometryReader { (proxy: GeometryProxy) in
                    let size: CGSize = proxy.size
                    Text("hu")
                }
            }
        } header: {
            Text("Input Nutrition Table")
                .productFont(.regular, relativeTo: .footnote)
        }
        .listRowInsets(.zero)
    }
}

fileprivate struct NutTableSession: View {
    let nut: NutritionInformation
    var body: some View {
        Section {
            VStack {
                NutRow(leading: "營養標籤", trailig: "每100毫升")
                NutRow(leading: "Nutrition Information", trailig: "Per 100mL")
            }
            NutRow(
                leading: "熱量 / Energy",
                trailig: "\(nut.energy)千卡/kcal"
            )
            NutRow(
                leading: "蛋白質 / Protein",
                trailig: "\(nut.protein.formatted())克/g"
            )
            VStack {
                NutRow(
                    leading: "脂肪總量 / Total Fat",
                    trailig: "\(nut.total_fat.formatted())克/g"
                )
                NutRow(
                    leading: "- 飽和脂肪 / Saturated Fat",
                    trailig: "\(nut.saturated_fat.formatted())克/g"
                )
                NutRow(
                    leading: "- 反式脂肪 / Trans Fat",
                    trailig: "\(nut.trans_fat.formatted())克/g"
                )
            }
            VStack {
                NutRow(
                    leading: "碳水化合物 / Carbohydrates",
                    trailig: "\(nut.carbohydrates.formatted())克/g"
                )
                NutRow(
                    leading: "- 糖 / Sugar",
                    trailig: "\(nut.sugars.formatted())克/g"
                )
            }
            NutRow(
                leading: "鈉 / Sodium",
                trailig: "\(nut.sodium.formatted())毫克/mg"
            )
            if let vitB2: Double = nut.vitaminB2 {
                NutRow(
                    leading: "維他命B2 / Vitamin B2",
                    trailig: "\(vitB2.formatted())毫克/mg"
                )
            }
            if let vitB3: Double = nut.vitaminB3 {
                NutRow(
                    leading: "維他命B3 / Vitamin B2",
                    trailig: "\(vitB3.formatted())毫克/mg"
                )
            }
            if let vitB6: Double = nut.vitaminB6 {
                NutRow(
                    leading: "維他命B6 / Vitamin B6",
                    trailig: "\(vitB6.formatted())毫克/mg"
                )
            }
            NutBarChart(nut: nut)
        } header: {
            Text("Nutrition Table")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct NutRow: View {
    let leading: String
    let trailig: String
    var body: some View {
        HStack {
            Text(leading)
                .foregroundColor(.primary)
            Spacer()
            Text(trailig)
                .foregroundColor(.secondary)
        }
        .productFont(.regular, relativeTo: .body)
    }
}

fileprivate struct NutBarChart: View {
    let nut: NutritionInformation
    let datas: [(String, Double)]
    init(nut: NutritionInformation) {
        self.nut = nut
        let energy = Double(nut.energy)
        let proteun: Double = nut.protein
        let satFat: Double = nut.saturated_fat
        let transFat: Double = nut.trans_fat
        let carbo: Double = nut.carbohydrates
        let sugar: Double = nut.sugars
        let sodium: Double = nut.sodium
        datas = [
            ("Energy", energy),
            ("Protein", proteun),
            ("Sat Fat", satFat),
            ("Tran Fat", transFat),
            ("Carbo", carbo),
            ("Sugar", sugar),
            ("Sodium", sodium)
        ]
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Nutrition Table")
                .foregroundColor(.primary)
                .productFont(.bold, relativeTo: .title3)
            Text("This product contains lots of sugar, think twice before eating")
            Chart(datas, id: \.0) { (data: (String, Double)) in
                BarMark(
                    x: .value("Nutrition Info", data.0),
                    y: .value("Nutrition Value", 10)
                )
            }
        }
        .padding(.vertical)
    }
}


struct InputProductDetailView_Previews: PreviewProvider {
    static var product = Product()
    static var previews: some View {
        NavigationStack {
            InputProductDetailView(
                detail: InputProductDetailView.Detail(product: product)
            )
        }
    }
}
