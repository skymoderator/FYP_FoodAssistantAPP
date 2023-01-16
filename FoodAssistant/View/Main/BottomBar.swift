//
//  BottomBar.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct BottomBar: View {
    
    @EnvironmentObject var mvm: MainViewModel
    let screenSize: CGSize
    let onLeadingButtonTap: () -> Void
    let onCenterButtonTap: () -> Void
    let isCenterButtonMorphing: Bool
    let onTrailingButtonTap: () -> Void
    let normalizedCurrentTabOffset: CGFloat
    let tabScrollProgress: CGFloat
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            VStack(spacing: 0) {
                CameraBottomBar(cvm: mvm.cvm)
                    .frame(
                        width: size.width,
                        height: 80 * tabScrollProgress
                    )
                    .opacity(tabScrollProgress)
                TabBar(
                    screenSize: screenSize,
                    onLeadingButtonTap: onLeadingButtonTap,
                    onCenterButtonTap: onCenterButtonTap,
                    isCenterButtonMorphing: isCenterButtonMorphing,
                    onTrailingButtonTap: onTrailingButtonTap,
                    normalizedCurrentTabOffset: normalizedCurrentTabOffset,
                    tabScrollProgress: tabScrollProgress
                )
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

