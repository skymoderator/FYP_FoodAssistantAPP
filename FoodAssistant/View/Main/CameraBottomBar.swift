//
//  CameraBottomBar.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import SwiftUI

struct CameraBottomBar: View {
    
    @ObservedObject var cvm: CameraViewModel
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            HStack {
                Group {
                    LeadingLeadingButton(cvm: cvm, size: size)
                    LeadingButton(cvm: cvm, size: size)
                    CenterButton(size: size)
                    TrailingButton(cvm: cvm, size: size)
                    TrailingTrailingButton(cvm: cvm, size: size)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .frame(width: size.width, height: size.height)
        }
    }
    
    fileprivate struct LeadingLeadingButton: View {
        @ObservedObject var cvm: CameraViewModel
        let size: CGSize
        var body: some View {
            SFButton("photo") {
                cvm.pickerService.showImagePicker.toggle()
            }
            .scaledToFit()
            .padding(12)
            .frame(
                width: max(0, size.height - 32),
                height: max(0, size.height - 32)
            )
            .background {
                Circle()
                    .fill(.regularMaterial)
            }
        }
    }

    fileprivate struct LeadingButton: View {
        @ObservedObject var cvm: CameraViewModel
        let size: CGSize
        var body: some View {
            SFButton("photo") {
                cvm.pickerService.showImagePicker.toggle()
            }
            .scaledToFit()
            .padding(12)
            .frame(
                width: max(0, size.height - 32),
                height: max(0, size.height - 32)
            )
            .background {
                Circle()
                    .fill(.regularMaterial)
            }
        }
    }

    fileprivate struct CenterButton: View {
        let size: CGSize
        var body: some View {
            SFButton("photo")
                .scaledToFit()
                .frame(
                    width: max(0, size.height - 32),
                    height: max(0, size.height - 32)
                )
                .opacity(0)
        }
    }

    fileprivate struct TrailingButton: View {
        @ObservedObject var cvm: CameraViewModel
        let size: CGSize
        var body: some View {
            SFButton(
                cvm.captureSource == nil ? "arrow.triangle.2.circlepath.camera" :
                    cvm.isScaleToFill ? "arrow.down.right.and.arrow.up.left.circle" : "arrow.up.backward.and.arrow.down.forward.circle") {
                    cvm.onTrailingButtonTapped()
                }
                    .scaledToFit()
                    .padding(12)
                    .frame(
                        width: max(0, size.height - 32),
                        height: max(0, size.height - 32)
                    )
                    .background {
                        Circle()
                            .fill(.regularMaterial)
                    }
        }
    }
    
    fileprivate struct TrailingTrailingButton: View {
        @ObservedObject var cvm: CameraViewModel
        let size: CGSize
        var body: some View {
            SFButton("flashlight.off.fill") {
                if cvm.cameraService.flashMode == .on {
                    cvm.cameraService.flashMode = .off
                } else {
                    cvm.cameraService.flashMode = .on
                }
            }
            .scaledToFit()
            .padding(12)
            .frame(
                width: max(0, size.height - 32),
                height: max(0, size.height - 32)
            )
            .background {
                Circle()
                    .fill(.regularMaterial)
            }
        }
    }
}

struct CameraBottomBar_Previews: PreviewProvider {
//    @StateObject static var mvm = MainViewModel()
    static var previews: some View {
//        GeometryReader { (proxy: GeometryProxy) in
//            let size: CGSize = proxy.size
//            ZStack {
//                Image("Appicon")
//                VStack {
//                    Spacer()
//                    CameraBottomBar(cvm: mvm.cvm)
//                        .frame(width: size.width, height: 80)
//                }
//                .frame(width: size.width, height: size.height)
//            }
//            .frame(width: size.width, height: size.height)
//        }
//        .edgesIgnoringSafeArea(.all)
        ContentView()
    }
}
