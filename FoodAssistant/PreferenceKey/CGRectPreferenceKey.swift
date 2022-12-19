//
//  CGSizePreferenceKey.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct CGRectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
