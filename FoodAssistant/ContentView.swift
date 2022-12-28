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
    @StateObject var foodproductListVM = FoodProductListViewModel()
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
                mvm.bottomBarVM.tabOffset = screenWidth
            }
        }
        .introspectScrollView { (s: UIScrollView) in
            s.isScrollEnabled = false
        }
        .overlay(alignment: .bottom) {
            BottomBar()
                .frame(
                    width: screenWidth,
                    height: screenHeight/8 + 80 * mvm.bottomBarVM.tabScrollProgress
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: mvm.bottomBarVM.showBar ? 0 : screenHeight/8 + 80)
        }
        .edgesIgnoringSafeArea(.all)
        .environmentObject(mvm)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
