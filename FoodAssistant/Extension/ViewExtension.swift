//
//  ViewExtension.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 12/12/2022.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
    
    func offset(space: String, completion: @escaping (CGRect)->()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .named(space))
                    Color
                        .clear
                        .preference(key: CGRectPreferenceKey.self, value: rect)
                        .onPreferenceChange(CGRectPreferenceKey.self) { value in
                            completion(value)
                        }
                }
            }
    }
}
