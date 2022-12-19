//
//  SettingView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            Text("Hello, World!")
        }
        .fullScreen()
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
