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
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        List {
            NameSession(vm: vm)
            InfoSession(vm: vm)
            NutTableSession(nut: vm.product.nutrition ?? NutritionInformation())
        }
        .navigationTitle("Product Detail")
        .productLargeNavigationBar()
        .onTapGesture {
            hideKeyboard()
        }
    }
}

fileprivate struct NameSession: View {
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        Section {
            ProductFontPlaceholderTextField(
                text: $vm.product.name,
                placeholder: "Product Name (e.g Coca Cola)"
            )
        } header: {
            Text("Name")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct InfoSession: View {
    @ObservedObject var vm: AddProductViewModel
    @State var showPopover = false
    @State var priceText = ""
    var body: some View {
        Section {
//            PriceRow(
//                price: vm.product.price.formatted(),
//                showPopover: $showPopover
//            )
            Row(
                image: "hammer.circle",
                color: .systemOrange,
                leading: "Manufacturer",
                trailig: vm.product.manufacturer ?? "Unknown"
            )
            Row(
                image: "bag.circle",
                color: .systemBlue,
                leading: "Brand",
                trailig: vm.product.brand ?? "Unknown"
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
                PricePopover()
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
        let price: String
        @Binding var showPopover: Bool
        var body: some View {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.red)
                Text("Price")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                Spacer()
                PricePopoverBut(show: $showPopover)
                Text("HKD $\(price)")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

fileprivate struct PricePopover: View {
    let datas: [(Date, Double)]
    init() {
        let dates: [Date] = (0...7).map { (i: Int) in
            Date() - i.days
        }
        let prices: [Double] = [10, 20, 30, 40, 30, 50, 60]
        datas = zip(dates, prices).map { ($0, $1) }
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
                    .frame(height: 200)
                    .padding(.vertical, 8)
                    VStack(spacing: 0) {
                        Row(
                            image: "distribute.vertical.top",
                            color: .systemRed,
                            leading: "Lowest:",
                            trailing: "HKD $10"
                        )
                        Divider()
                        Row(
                            image: "distribute.vertical.bottom",
                            color: .systemOrange,
                            leading: "Highest:",
                            trailing: "HKD $20"
                        )
                        Divider()
                        Row(
                            image: "distribute.vertical.center",
                            color: .systemBlue,
                            leading: "Medium:",
                            trailing: "HKD $15"
                        )
                    }
                    .background(.adaptable(light: .white, dark: .systemGray6))
                    .cornerRadius(10, style: .continuous)
                }
                .padding()
            }
            .frame(height: 400)
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
    @StateObject static var vm = AddProductViewModel()
    static var previews: some View {
        NavigationStack {
            InputProductDetailView(vm: vm)
        }
    }
}
