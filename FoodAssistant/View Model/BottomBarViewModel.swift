//
//  BottomBarViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import Foundation
import UIKit

class BottomBarViewModel: NSObject, ObservableObject {
    
    @Published var tabOffset: CGFloat = 0
    @Published var showBar = true
    @Published var scrollable = true
    
    var tabSV: UIScrollView?
    
    var normalizedTabOffset: CGFloat {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        return tabOffset/CGFloat(screenWidth)
    }
    
    var tabScrollProgress: CGFloat {
        let progress: CGFloat = normalizedTabOffset <= 1 ? normalizedTabOffset : 2 - normalizedTabOffset
        return max(0, min(2, progress))
    }
    
}

extension BottomBarViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tabSV else { return }
        tabOffset = tabSV.contentOffset.x
    }
}

