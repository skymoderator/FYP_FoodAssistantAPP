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
        ScrollView(.vertical) {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    CatagoryView()
                    CameraView()
                    SettingView()
                }
            }
            .scrollDisabled(!mvm.bottomBarVM.scrollable)
            .introspectScrollView { (s: UIScrollView) in
                if mvm.bottomBarVM.tabSV == nil {
                    mvm.bottomBarVM.tabSV = s
                }
                s.delegate = mvm.bottomBarVM
                s.isPagingEnabled = true
                s.setContentOffset(
                    .init(x: screenWidth, y: 0),
                    animated: false)
                mvm.bottomBarVM.normalizedCurrentTabOffset = 1
            }
        }
        .introspectScrollView { (s: UIScrollView) in
            s.isScrollEnabled = false
        }
        .overlay(alignment: .bottom) {
            BottomBar()
                .frame(width: screenWidth, height: bottomBarHeight, alignment: .bottom)
                .offset(y: mvm.bottomBarVM.showBar ? 0 : bottomBarMaxHeight)
        }
        .edgesIgnoringSafeArea(.all)
        .environmentObject(mvm)
        .onRotate { (d: UIDeviceOrientation) in
            if d == .portrait || d == .landscapeLeft || d == .landscapeRight {
                mvm.isPortrait = d.isPortrait
                mvm.handleDeviceOrientationChanges()
            }
        }
    }
    
    var bottomBarHeight: CGFloat {
        min(160, screenHeight/8) + tabBarMaxHeight * mvm.bottomBarVM.tabScrollProgress
    }
    
    var bottomBarMaxHeight: CGFloat {
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
