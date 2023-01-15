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
                    CatagoryView(screenSize: mvm.screenSize)
                    CameraView()
                    SettingView()
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
            BottomBar()
                .frame(width: mvm.screenWidth, height: bottomBarHeight, alignment: .bottom)
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
        min(160, mvm.screenHeight/8) + tabBarMaxHeight * mvm.bottomBarVM.tabScrollProgress
    }
    
    var bottomBarMaxHeight: CGFloat {
        min(160, mvm.screenHeight/8) + tabBarMaxHeight
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
