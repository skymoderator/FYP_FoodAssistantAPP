//
//  SettingView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct SettingView: View {
    @StateObject var vm = SettingViewModel()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    General()
                } footer: {
                    Rectangle()
                        .frame(height: screenHeight/8)
                        .opacity(0)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("Setting")
            .nativeSearchBar(text: $vm.searchedSetting, placeHolder: "Search Setting")
        }
        .productLargeNavigationBar()
        .frame(width: screenWidth)
    }
}

fileprivate struct General: View {
    var body: some View {
        HStack {
            Image(systemName: "gear")
                .foregroundColor(.white)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundColor(.systemGray)
                }
            Text("General")
                .productFont(.regular, relativeTo: .body)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
