//
//  BarCodeIndicatorView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import SwiftUI

struct BarCodeIndicatorView: View {
    
    let barcode: String
    let height: CGFloat
    
    var body: some View {
        GeometryReader { (proxy: GeometryProxy) in
            let width: CGFloat = proxy.size.width-96
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .opacity(0.4)
                VStack {
                    Text("Place Barcode Inside")
                        .foregroundColor(.white)
                        .productFont(.bold, relativeTo: .body)
                    Rectangle()
                        .frame(width: width, height: height)
                        .cornerRadius(10)
                        .blendMode(.destinationOut)
                        .overlay {
                            RoundedRectangleCorners()
                                .stroke(lineWidth: 5)
                                .fill(.white)
                        }
                        .overlay {
                            Text(barcode)
                                .productFont(.bold, relativeTo: .title2)
                                .foregroundColor(.white)
                        }
                }
            }
            .compositingGroup()
        }
    }
}

struct BarCodeIndicatorView_Previews: PreviewProvider {
    static let barcode = "4891028714842"
    static var previews: some View {
        BarCodeIndicatorView(barcode: barcode, height: 150)
    }
}
