//
//  CameraBottomBar.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 16/11/2022.
//

import SwiftUI

struct CameraBottomBar: View {
    
    let onLeadingLeadingButTap: () -> Void
    let onLeadingButTap: () -> Void
    let onTrailingButTap: () -> Void
    let onTrailingTrailingButTap: () -> Void
    let isPhotoCaptured: Bool
    let isScaleToFit: Bool
    let isFlashLightOn: Bool
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let size: CGSize = proxy.size
            HStack {
                Group {
                    LeadingLeadingButton(
                        size: size,
                        onTap: onLeadingLeadingButTap
                    )
                    LeadingButton(
                        size: size,
                        onTap: onLeadingButTap
                    )
                    CenterButton(size: size)
                    TrailingButton(
                        size: size,
                        isPhotoCaptured: isPhotoCaptured,
                        isScaleToFit: isScaleToFit,
                        onTap: onTrailingButTap
                    )
                    TrailingTrailingButton(
                        size: size,
                        isFlashLightOn: isFlashLightOn,
                        onTap: onTrailingTrailingButTap
                    )
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .frame(width: size.width, height: size.height)
        }
    }
    
    fileprivate struct LeadingLeadingButton: View {
        let size: CGSize
        let onTap: () -> Void
        var body: some View {
            SFButton("photo", action: onTap)
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
        let size: CGSize
        let onTap: () -> Void
        var body: some View {
            SFButton("photo", action: onTap)
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
        let size: CGSize
        let isPhotoCaptured: Bool
        let isScaleToFit: Bool
        let onTap: () -> Void
        var body: some View {
            SFButton(
                !isPhotoCaptured ? "arrow.triangle.2.circlepath.camera" :
                    (isScaleToFit ?  "arrow.down.right.and.arrow.up.left.circle" : "arrow.up.backward.and.arrow.down.forward.circle"),
                action: onTap
            )
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
        let size: CGSize
        let isFlashLightOn: Bool
        let onTap: () -> Void
        var body: some View {
            SFButton(isFlashLightOn ? "bolt.slash.circle" : "bolt.circle", action: onTap)
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
    static var previews: some View {
        ContentView()
    }
}
