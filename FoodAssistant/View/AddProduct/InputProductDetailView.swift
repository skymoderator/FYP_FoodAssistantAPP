//
//  InputProductDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/12/2022.
//

import SwiftUI
import Popovers
import Introspect

struct InputProductDetailView: View {
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        List {
            NameSession(vm: vm)
            PriceSession(vm: vm)
        }
        .navigationTitle("Product Name")
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
            Text("Product Name")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct PriceSession: View {
    @ObservedObject var vm: AddProductViewModel
    @State var showPopover = false
    @State var priceText = ""
    var body: some View {
        Section {
            HStack {
                Text("$")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.primary)
                TextField(
                    "Product Price (e.g 10)",
                    text: $priceText
                )
                .introspectTextField { (tf: UITextField) in
                    tf.attributedPlaceholder = "Product Price (e.g 10)"
                        .productAttribute(
                            .regular,
                            relativeTo: .body,
                            color: .secondary
                        )
                }
                .keyboardType(.numberPad)
                .onSubmit {
                    if let price = Double(priceText) {
                        vm.product.price = price
                    } else {
                        vm.product.price = 0
                        priceText = ""
                    }

                }
                .productFont(.regular, relativeTo: .body)
                .foregroundColor(.primary)
                
                Button {
                    showPopover = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.systemBlue)
                }
                .buttonStyle(.plain)
                .popover(
                    present: $showPopover,
                    attributes: { (a: inout Popover.Attributes) in
                        a.position = .absolute(
                            originAnchor: .bottom,
                            popoverAnchor: .topRight
                        )
                        a.rubberBandingMode = .none
                        a.sourceFrameInset.bottom = -32
                    }
                ) {
                    PricePopover(vm: vm)
                }
            }
        } header: {
            Text("Price")
                .productFont(.regular, relativeTo: .footnote)
        }
    }
}

fileprivate struct PricePopover: View {
    @ObservedObject var vm: AddProductViewModel
    var body: some View {
        Templates.Container(
            arrowSide: .top(.mostClockwise),
            cornerRadius: 20
        ) {
            ScrollView(.horizontal) {
                HStack {
                    PricePopoverButton(vm: vm, price: 10)
                    PricePopoverButton(vm: vm, price: 20)
                    PricePopoverButton(vm: vm, price: 50)
                    PricePopoverButton(vm: vm, price: 100)
                }
            }
        }
    }
}

fileprivate struct PricePopoverButton: View {
    @ObservedObject var vm: AddProductViewModel
    let price: Int
    var body: some View {
        Button {
            vm.product.price += Double(price)
        } label: {
            Text("+\(price)")
                .productFont(.bold, relativeTo: .body)
                .foregroundColor(.systemBlue)
                .frame(width: 50, height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.systemBlue, lineWidth: 2)
                }
        }
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
