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
        let boundingBox: BoundingBox?
        let nutritionTablePhoto: Photo?
        /// The boolean value indicates whether or not the users
        /// can edit the data of the product
        let editable: Bool
        /// onAppear: Perform some logics when view appears,
        /// e.g. hide tab bar and lock the scrollview from scrollable
        let onAppear: (() -> Void)?
        /// onDisappear: Similarly, reset back the logics performed on onAppear
        /// when view disappears
        let onDisappear: (() -> Void)?
        
        init(
            product: Product,
            boundingBox: BoundingBox? = nil,
            nutritionTablePhoto: Photo? = nil,
            editable: Bool = false,
            onAppear: (() -> Void)? = nil,
            onDisappear: (() -> Void)? = nil
        ) {
            self.product = product
            self.boundingBox = boundingBox
            self.nutritionTablePhoto = nutritionTablePhoto
            self.editable = editable
            self.onAppear = onAppear
            self.onDisappear = onDisappear
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: InputProductDetailViewModel
    let onAppear: (() -> Void)?
    let onDisappear: (() -> Void)?
    
    init(detail: Detail) {
        self._vm = StateObject(
            wrappedValue: InputProductDetailViewModel(
                product: detail.product,
                boundingBox: detail.boundingBox,
                nutritionTablePhoto: detail.nutritionTablePhoto,
                editable: detail.editable
            )
        )
        self.onAppear = detail.onAppear
        self.onDisappear = detail.onDisappear
    }
    
    var body: some View {
        List {
            BarcodeSession(
                barcode: $vm.barcode,
                editable: vm.editable
            )
            NameSession(
                name: $vm.name,
                editable: vm.editable
            )
            InfoSession(
                product: vm.product,
                editable: vm.editable,
                price: $vm.price,
                manufacturer: $vm.manufacturer,
                brand: $vm.brand
            )
            NutTableSession(
                energy: $vm.energy,
                protein: $vm.protein,
                totalFat: $vm.totalFat,
                saturatedFat: $vm.saturatedFat,
                transFat: $vm.transFat,
                carbohydrates: $vm.carbohydrates,
                sugars: $vm.sugars,
                sodium: $vm.sodium,
                vitaminB2: $vm.vitaminB2,
                vitaminB3: $vm.vitaminB3,
                vitaminB6: $vm.vitaminB6,
                editable: vm.editable
            )
            if let bbox: BoundingBox = vm.boundingBox,
               let photo: Photo = vm.nutritionTablePhoto {
                BoundingBoxSession(photo: photo, bbox: bbox)
            }
        }
        .navigationTitle("Product Detail")
        .productLargeNavigationBar()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    /// Only show the Done button (for uploading product information to server)
                    /// when it is editable (that's means there is no record on server), otherwise,
                    /// user should not be able to edit the inforamtion and thus no need to show the
                    /// done button
                    if vm.editable {
                        vm.showDismissAlert = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Done")
                        .productFont(.bold, relativeTo: .body)
                        .foregroundColor(.systemBlue)
                }
            }
        }
        .alert("Oops", isPresented: $vm.showDismissAlert) {
            Button(role: .cancel) {
                vm.uploadProductInformationToServer()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Yes Sure")
            }
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("No thanks")
            }
        } message: {
            Text("Looks like this product is not on our server records, do you want to upload this product information to our server?")
        }
        .interactiveDismissDisabled(true)
    }
}

fileprivate struct BarcodeSession: View {
    @Binding var barcode: String
    let editable: Bool
    var body: some View {
        Section {
            ProductFontPlaceholderTextField(
                text: Binding<String?>(
                    get: { barcode },
                    set: { barcode = $0 ?? "" }
                ),
                placeholder: "13-digit Product Barcode",
                keyboardType: .numberPad,
                editable: editable
            )
        } header: {
            Text("Barcode")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct NameSession: View {
    @Binding var name: String
    let editable: Bool
    var body: some View {
        Section {
            ProductFontPlaceholderTextField(
                text: Binding<String?>(
                    get: { name },
                    set: { name = $0 ?? "" }
                ),
                placeholder: "Product Name (e.g Coca Cola)",
                editable: editable
            )
        } header: {
            Text("Name")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct InfoSession: View {
    let product: Product
    let editable: Bool
    @State var showPopover = false
    @Binding var price: Double?
    @Binding var manufacturer: String?
    @Binding var brand: String?
    var body: some View {
        Section {
            PriceRow(
                prices: product.prices,
                editable: editable,
                showPopover: $showPopover,
                price: $price
            )
            Row(
                image: "hammer.circle",
                color: .systemOrange,
                leading: "Manufacturer",
                editable: editable,
                trailig: $manufacturer
            )
            Row(
                image: "bag.circle",
                color: .systemBlue,
                leading: "Brand",
                editable: editable,
                trailig: $brand
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
        let prices: [ProductPrice]
        @Binding var show: Bool
        var body: some View {
            Button {
                show.toggle()
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis.circle")
                    .foregroundColor(.systemBlue)
            }
            .buttonStyle(.plain)
            .hoverEffect()
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
                PricePopover(prices: prices)
            }
        }
    }
    
    private struct Row: View {
        let image: String
        let color: Color
        let leading: String
        let editable: Bool
        @Binding var trailig: String?
        var body: some View {
            HStack {
                Image(systemName: image)
                    .foregroundColor(color)
                Text(leading)
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                Spacer()
                ProductFontPlaceholderTextField(
                    text: Binding<String?>(
                        get: { trailig == nil ? nil : trailig! },
                        set: { trailig = $0 }
                    ),
                    placeholder: "Unknown",
                    editable: editable
                )
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
    
    private struct PriceRow: View {
        let prices: [ProductPrice]
        let editable: Bool
        @Binding var showPopover: Bool
        @Binding var price: Double?
        var body: some View {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.red)
                Text("Price")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                Spacer()
                /// If not editable, that means there is a record on the server, then that means
                /// there are price trend data availabe, then we show the price popver button
                if !editable {
                    PricePopoverBut(prices: prices, show: $showPopover)
                }
                HStack(spacing: 0) {
                    Text("HKD $")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                    ProductFontPlaceholderTextField(
                        text: Binding<String?>(
                            get: { price == nil ? nil : "\(price!)" },
                            set: { price = Double($0 ?? "") }
                        ),
                        placeholder: "NA",
                        keyboardType: .numberPad,
                        editable: editable
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
}

fileprivate struct PricePopover: View {
    let datas: [(Date, Double)]
    let minPrice: Double
    let maxPrice: Double
    let avgPrice: Double
    init(prices: [ProductPrice]) {
        let dates: [Date] = prices.map { $0.date }
        let prices: [Double] = prices.map { $0.price }
        datas = zip(dates, prices).map { ($0, $1) }
        minPrice = prices.min() ?? 0
        maxPrice = prices.max() ?? 0
        avgPrice = prices.reduce(0.0, +)/Double(prices.count)
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

fileprivate struct BoundingBoxSession: View {
    let photo: Photo
    let bbox: BoundingBox
    var body: some View {
        Section {
            if let image: UIImage = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        GeometryReader { (proxy: GeometryProxy) in
                            let size: CGSize = proxy.size
                            BoundingBoxView(
                                boundingBoxes: [bbox],
                                size: size,
                                rescaledSize: photo.rescaledImage?.size ?? .zero
                            )
                        }
                    }
            }
        } header: {
            Text("Nutrition Table")
                .productFont(.regular, relativeTo: .footnote)
        } footer: {
            Text("Disclaimer: The bounding box is predicted by custom-made Machine Learning model, which maybe inaccurate")
                .productFont(.regular, relativeTo: .footnote)
                .foregroundColor(.secondary)
        }
        .listRowInsets(.init(top: 8, leading: 0, bottom: 0, trailing: 0))
    }
}

fileprivate struct NutTableSession: View {
    @Binding var energy: String?
    @Binding var protein: String?
    @Binding var totalFat: String?
    @Binding var saturatedFat: String?
    @Binding var transFat: String?
    @Binding var carbohydrates: String?
    @Binding var sugars: String?
    @Binding var sodium: String?
    @Binding var vitaminB2: String?
    @Binding var vitaminB3: String?
    @Binding var vitaminB6: String?
    let editable: Bool
    
    var body: some View {
        Section {
            VStack {
                NutRow(
                    leading: "營養標籤",
                    unit: "",
                    editable: false,
                    trailing: Binding<String?>.constant("每100毫升")
                )
                NutRow(
                    leading: "Nutrition Information",
                    unit: "",
                    editable: false,
                    trailing: Binding<String?>.constant("Per 100mL")
                )
            }
            NutRow(
                leading: "熱量 / Energy",
                unit: "千卡/kcal",
                editable: editable,
                trailing: $energy
            )
            NutRow(
                leading: "蛋白質 / Protein",
                unit: "克/g",
                editable: editable,
                trailing: $protein
            )
            VStack {
                NutRow(
                    leading: "脂肪總量 / Total Fat",
                    unit: "克/g",
                    editable: editable,
                    trailing: $totalFat
                )
                NutRow(
                    leading: "- 飽和脂肪 / Saturated Fat",
                    unit: "克/g",
                    editable: editable,
                    trailing: $saturatedFat
                )
                NutRow(
                    leading: "- 反式脂肪 / Trans Fat",
                    unit: "克/g",
                    editable: editable,
                    trailing: $transFat
                )
            }
            VStack {
                NutRow(
                    leading: "碳水化合物 / Carbohydrates",
                    unit: "克/g",
                    editable: editable,
                    trailing: $carbohydrates
                )
                NutRow(
                    leading: "- 糖 / Sugar",
                    unit: "克/g",
                    editable: editable,
                    trailing: $sugars
                )
            }
            NutRow(
                leading: "鈉 / Sodium",
                unit: "克/g",
                editable: editable,
                trailing: $sodium
            )
            if vitaminB2 != nil {
                NutRow(
                    leading: "維他命B2 / Vitamin B2",
                    unit: "毫克/mg",
                    editable: editable,
                    trailing: $vitaminB2
                )
            }
            if vitaminB3 != nil {
                NutRow(
                    leading: "維他命B3 / Vitamin B3",
                    unit: "毫克/mg",
                    editable: editable,
                    trailing: $vitaminB3
                )
            }
            if vitaminB6 != nil {
                NutRow(
                    leading: "維他命B6 / Vitamin B6",
                    unit: "毫克/mg",
                    editable: editable,
                    trailing: $vitaminB6
                )
            }
            NutBarChart(
                energy: $energy,
                protein: $protein,
                saturatedFat: $saturatedFat,
                transFat: $transFat,
                carbohydrates: $carbohydrates,
                sugars: $sugars,
                sodium: $sodium
            )
        } header: {
            Text("Nutrition Table")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
    
    fileprivate struct NutBarChart: View {
        @Binding var energy: String?
        @Binding var protein: String?
        @Binding var saturatedFat: String?
        @Binding var transFat: String?
        @Binding var carbohydrates: String?
        @Binding var sugars: String?
        @Binding var sodium: String?
        var datas: [(String, Double)] {
            [
                ("Energy", Double(energy ?? "") ?? 0),
                ("Protein", Double(protein ?? "") ?? 0),
                ("Sat Fat", Double(saturatedFat ?? "") ?? 0),
                ("Tran Fat", Double(transFat ?? "") ?? 0),
                ("Carbo", Double(carbohydrates ?? "") ?? 0),
                ("Sugar", Double(sugars ?? "") ?? 0),
                ("Sodium", Double(sodium ?? "") ?? 0)
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
                        y: .value("Nutrition Value", data.1)
                    )
                }
                .animation(.easeInOut, value: energy)
                .animation(.easeInOut, value: protein)
                .animation(.easeInOut, value: saturatedFat)
                .animation(.easeInOut, value: transFat)
                .animation(.easeInOut, value: carbohydrates)
                .animation(.easeInOut, value: sugars)
                .animation(.easeInOut, value: sodium)
            }
            .padding(.vertical)
        }
    }
    
    fileprivate struct NutRow: View {
        let leading: String
        let unit: String
        let editable: Bool
        @Binding var trailing: String?
        var body: some View {
            HStack {
                Text(leading)
                    .foregroundColor(.primary)
                Spacer()
                HStack(spacing: 0) {
                    ProductFontPlaceholderTextField(
                        text: $trailing,
                        placeholder: "0",
                        keyboardType: .numbersAndPunctuation,
                        editable: editable
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    Text(unit)
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
            }
            .productFont(.regular, relativeTo: .body)
        }
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
