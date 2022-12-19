//
//  LoadingScreen.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        Image("Appicon")
            .resizable()
            .scaledToFit()
            .frame(width: screenWidth/3, height: screenWidth/3)
            .frame(width: screenWidth, height: screenHeight)
            .background(.white)
    }
}

struct LaunchScreen_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreen()
    }
}
