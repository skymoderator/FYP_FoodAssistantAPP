//
//  TabBar.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 17/11/2022.
//

import SwiftUI

struct TabBar: View {
    
    @ObservedObject var mvm: MainViewModel
    @ObservedObject var cvm: CameraViewModel
    @Environment(\.safeAreaInsets) var safeArea
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            HStack {
                LeadingButton(mvm: mvm)
                CenterButton(mvm: mvm, cvm: cvm)
                TrailingButton(mvm: mvm)
            }
            .padding(.bottom, safeArea.bottom)
            .frame(width: size.width, height: size.height)
        }
    }
    
    fileprivate struct LeadingButton: View {
        @ObservedObject var mvm: MainViewModel
        @Environment(\.safeAreaInsets) var safeArea
        var body: some View {
            GeometryReader { (proxy: GeometryProxy) in
                let height: CGFloat = proxy.size.height
                let size: CGFloat = min(50, height)
                ZStack {
                    Color.blue
                    Color.primary
                        .opacity(min(1, mvm.bottomBarVM.normalizedCurrentTabOffset))
                }
                .mask {
                    SFButton("list.dash")
                        .scaledToFit()
                        .frame(width: size, height: size)
                }
                .frame(width: size, height: size - (mvm.isPortrait ? 0 : 10))
                .padding(.top, mvm.isPortrait ? 0 : 10)
                .onTapGesture {
                    withAnimation {
                        mvm.bottomBarVM.scrollTo(page: .one, animated: false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    fileprivate struct CenterButton: View {
        @ObservedObject var mvm: MainViewModel
        @ObservedObject var cvm: CameraViewModel
        @Environment(\.safeAreaInsets) var safeArea
        var body: some View {
            GeometryReader { (proxy: GeometryProxy) in
                let height: CGFloat = proxy.size.height
                let size: CGFloat = min(50, height)
                ZStack {
                    Color.blue
                    Color.primary
                        .opacity(
                            mvm.bottomBarVM.normalizedCurrentTabOffset <= 1 ?
                            1 - mvm.bottomBarVM.normalizedCurrentTabOffset :
                                mvm.bottomBarVM.normalizedCurrentTabOffset - 1
                        )
                }
                .mask {
                    MorphingView(isTapped: Binding<Bool>(
                        get: { cvm.captureSource != nil },
                        set: { _ in }
                    ))
                }
                .frame(width: size, height: size - (mvm.isPortrait ? 0 : 10))
                .padding(.top, mvm.isPortrait ? 0 : 10)
                .scaleEffect(
                    1 + mvm.bottomBarVM.tabScrollProgress,
                    anchor: .bottom)
                .onTapGesture {
                    if mvm.bottomBarVM.normalizedCurrentTabOffset != 1 {
                        mvm.bottomBarVM.scrollTo(page: .two, animated: true)
                    } else {
                        cvm.onSnapButtonTapped()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    fileprivate struct TrailingButton: View {
        @ObservedObject var mvm: MainViewModel
        @Environment(\.safeAreaInsets) var safeArea
        var body: some View {
            GeometryReader { (proxy: GeometryProxy) in
                let height: CGFloat = proxy.size.height
                let size: CGFloat = min(50, height)
                ZStack {
                    Color.blue
                    Color.primary
                        .opacity(2 - mvm.bottomBarVM.normalizedCurrentTabOffset)
                }
                .mask {
                    SFButton("gear.circle")
                        .scaledToFit()
                }
                .frame(width: size, height: size - (mvm.isPortrait ? 0 : 10))
                .padding(.top, mvm.isPortrait ? 0 : 10)
                .onTapGesture {
                    withAnimation {
                        mvm.bottomBarVM.scrollTo(page: .three, animated: false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


struct TabBar_Previews: PreviewProvider {
//    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let size: CGSize = proxy.size
//            ZStack {
//                Image("Appicon")
//                VStack {
//                    Spacer()
//                    TabBar(mvm: mvm, cvm: mvm.cvm)
//                        .frame(width: size.width, height: min(size.height/8, 80))
//                }
//                .frame(width: size.width, height: size.height)
//            }
//            .frame(width: size.width, height: size.height)
//        }
//        .edgesIgnoringSafeArea(.all)
        ContentView()
    }
}
