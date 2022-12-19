//
//  ProductFontPlaceholderTextField.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/12/2022.
//

import SwiftUI

struct ProductFontPlaceholderTextField: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let onCommit: (() -> Void)?
    
    init(
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.onCommit = onCommit
    }
    
    var body: some View {
        TextField("", text: $text, onCommit: {
            self.onCommit?()
        })
            .productFont(.regular, relativeTo: .body)
            .background {
                Text(placeholder)
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.secondary)
                    .opacity(text.isEmpty ? 1 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .keyboardType(keyboardType)
            .onTapGesture {
                print(text)
            }
    }
}
struct ProductFontPlaceholderTextField_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        ProductFontPlaceholderTextField(
            text: $text,
            placeholder: "Product Barcode (e.g 4891028714842)"
        )
    }
}
