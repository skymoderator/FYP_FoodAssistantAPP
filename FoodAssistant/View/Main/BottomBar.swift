//
//  BottomBar.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct BottomBar: View {
    
    @EnvironmentObject var mvm: MainViewModel
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            VStack(spacing: 0) {
                CameraBottomBar(cvm: mvm.cvm)
                    .frame(
                        width: size.width,
                        height: 80 * mvm.bottomBarVM.tabScrollProgress)
                    .opacity(mvm.bottomBarVM.tabScrollProgress)
                TabBar(mvm: mvm, cvm: mvm.cvm)
            }
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        }
    }
    
}

struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

