//
//  ContentView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 23/10/2022.
//

import SwiftUI
import Introspect

struct ContentView: View {
    
    @StateObject var mvm = MainViewModel()
    @Namespace var nspace
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let screenSize: CGSize = proxy.size
            ScrollView(.vertical) {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        CatagoryView(screenSize: screenSize)
                        CameraView(screenSize: screenSize)
                        SettingView(screenSize: screenSize)
                    }
                }
                .introspectScrollView { (s: UIScrollView) in
                    if mvm.bottomBarVM.tabSV == nil {
                        mvm.bottomBarVM.tabSV = s
                    }
                    s.delegate = mvm.bottomBarVM
                    s.isPagingEnabled = true
                    mvm.bottomBarVM.scrollTo(page: .one, animated: false)
                }
            }
            .introspectScrollView { (s: UIScrollView) in
                s.isScrollEnabled = false
            }
            .overlay(alignment: .bottom) {
                BottomBar(
                    screenSize: screenSize,
                    onLeadingButtonTap: mvm.bottomTabBarOnLeadingButTap,
                    onCenterButtonTap: mvm.bottomTabBarOnCenterButTap,
                    isCenterButtonMorphing: mvm.isCenterButMorphing,
                    onTrailingButtonTap: mvm.bottomTabBarOnTrailingButTap,
                    normalizedCurrentTabOffset: mvm.bottomBarVM.normalizedCurrentTabOffset,
                    tabScrollProgress: mvm.bottomBarVM.tabScrollProgress
                )
                .frame(
                    width: screenSize.width,
                    height: bottomBarHeight(screenHeight: screenSize.height),
                    alignment: .bottom
                )
                .offset(
                    y: mvm.bottomBarVM.showBar ? 0 : bottomBarMaxHeight(screenHeight: screenSize.height)
                )
                .animation(.spring(), value: mvm.bottomBarVM.showBar)
            }
            .edgesIgnoringSafeArea(.all)
            .environmentObject(mvm)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func bottomBarHeight(screenHeight: CGFloat) -> CGFloat {
        min(160, screenHeight/8) + tabBarMaxHeight * mvm.bottomBarVM.tabScrollProgress
    }
    
    func bottomBarMaxHeight(screenHeight: CGFloat) -> CGFloat {
        min(160, screenHeight/8) + tabBarMaxHeight
    }
    
    var tabBarMaxHeight: CGFloat {
        80
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
