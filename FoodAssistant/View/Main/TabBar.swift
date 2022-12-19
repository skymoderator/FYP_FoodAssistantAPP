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
                Group {
                    LeadingButton(mvm: mvm, size: size)
                    CenterButton(mvm: mvm, cvm: cvm, size: size)
                    TrailingButton(mvm: mvm, size: size)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, safeArea.bottom)
            .frame(width: size.width, height: size.height)
        }
    }
    
    fileprivate struct LeadingButton: View {
        @ObservedObject var mvm: MainViewModel
        let size: CGSize
        var body: some View {
            ZStack {
                Color.blue
                Color.primary
                    .opacity(min(1, mvm.bottomBarVM.normalizedTabOffset))
            }
            .mask {
                SFButton("list.dash")
                    .scaledToFit()
                    .frame(width: size.height - 72, height: size.height - 72)
            }
            .onTapGesture {
                withAnimation {
                    mvm.bottomBarVM.tabSV?.setContentOffset(
                        .init(x: 0, y: 0),
                        animated: false
                    )
                    mvm.bottomBarVM.tabOffset = 0
                }
            }
        }
    }

    fileprivate struct CenterButton: View {
        @ObservedObject var mvm: MainViewModel
        @ObservedObject var cvm: CameraViewModel
        let size: CGSize
        var body: some View {
            ZStack {
                Color.blue
                Color.primary
                    .opacity(
                        mvm.bottomBarVM.normalizedTabOffset <= 1 ?
                        1 - mvm.bottomBarVM.normalizedTabOffset :
                            mvm.bottomBarVM.normalizedTabOffset - 1
                    )
            }
            .mask {
                MorphingView(isTapped: Binding<Bool>(
                    get: { cvm.captureSource != nil },
                    set: { _ in }
                ))
            }
            .frame(width: size.height - 72, height: size.height - 72)
            .scaleEffect(
                1 + mvm.bottomBarVM.tabScrollProgress,
                anchor: .bottom)
            .onTapGesture {
                if mvm.bottomBarVM.tabOffset != screenWidth {
                    mvm.bottomBarVM.tabSV?.setContentOffset(
                        .init(x: screenWidth, y: 0),
                        animated: true
                    )
                    mvm.bottomBarVM.tabOffset = screenWidth
                } else {
                    cvm.onSnapButtonTapped()
                }
            }
        }
    }

    fileprivate struct TrailingButton: View {
        @ObservedObject var mvm: MainViewModel
        let size: CGSize
        var body: some View {
            ZStack {
                Color.blue
                Color.primary
                    .opacity(2 - mvm.bottomBarVM.normalizedTabOffset)
            }
            .mask {
                SFButton("gear.circle")
                    .scaledToFit()
                    .frame(width: size.height - 72, height: size.height - 72)
            }
            .onTapGesture {
                withAnimation {
                    mvm.bottomBarVM.tabSV?.setContentOffset(
                        .init(x: screenWidth*2, y: 0),
                        animated: false
                    )
                    mvm.bottomBarVM.tabOffset = screenWidth*2
                }
            }
        }
    }
}


struct TabBar_Previews: PreviewProvider {
    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            ZStack {
                Image("Appicon")
                VStack {
                    Spacer()
                    TabBar(mvm: mvm, cvm: mvm.cvm)
                        .frame(width: size.width, height: size.height/8)
                }
                .frame(width: size.width, height: size.height)
            }
            .frame(width: size.width, height: size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
