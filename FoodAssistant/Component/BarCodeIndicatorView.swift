//
//  BarCodeIndicatorView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import SwiftUI

struct BarCodeIndicatorView: View {
    
    let barcode: String
    let width: CGFloat
    let height: CGFloat
    let offset: CGPoint
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.4)
            Rectangle()
                .frame(width: width, height: height)
                .cornerRadius(10)
                .blur(radius: 10)
                .blendMode(.destinationOut)
                .overlay {
                    RoundedRectangleCorners()
                        .stroke(lineWidth: 5)
                        .fill(.yellow)
                        .shadow(color: .systemYellow, radius: 10)
                }
                .overlay {
                    Text(barcode)
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                        .shadow(color: .adaptable(light: .white, dark: .black), radius: 10)
                }
                .offset(offset)
        }
        .compositingGroup()
    }
}
