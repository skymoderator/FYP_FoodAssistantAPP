//
//  ScreenDimensionExtension.swift
//  CirGo
//
//  Created by Choi Wai Lap on 13/7/2022.
//

import Foundation
import SwiftUI

extension View {
    
    var screenRect: CGSize { UIScreen.main.bounds.size }
    var screenWidth: CGFloat { screenRect.width }
    var screenHeight: CGFloat { screenRect.height }

}
