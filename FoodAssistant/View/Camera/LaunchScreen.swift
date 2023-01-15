//
//  LoadingScreen.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import SwiftUI

struct LaunchScreen: View {
    @EnvironmentObject var mvm: MainViewModel
    var body: some View {
        Image("Appicon")
            .resizable()
            .scaledToFit()
            .frame(width: mvm.screenWidth/3, height: mvm.screenWidth/3)
            .frame(width: mvm.screenWidth, height: mvm.screenHeight)
            .background(.white)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
        LaunchScreen()
            .environmentObject(mvm)
    }
}
