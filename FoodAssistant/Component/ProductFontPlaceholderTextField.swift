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
    
    /// Initialize `ProductFontPlaceholderTextField` view
    ///
    /// - Parameters:
    ///   - text: a `Binding<String>` object which links to textfield's value
    ///   - placeHolder: a placeholder `String`
    ///   - keyboardType: textfield keyboard type in `UIKeyboardType` type
    ///   - onCommit: an optional closure to be triggered when user tap on `Enter` button on keyboarrd
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
