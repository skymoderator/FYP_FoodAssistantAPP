//
//  BottomBarViewModel.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 6/12/2022.
//

import Foundation
import UIKit

class BottomBarViewModel: NSObject, ObservableObject {
    
    enum PageNumber: CGFloat {
        case one = 0, two = 1, three = 2
    }
    
    @Published private var tabOffset: CGFloat = 0
    @Published var normalizedCurrentTabOffset: CGFloat = 0
    @Published var showBar = true
    @Published var scrollable = true
    @Published var pageChange = true // just a dummy publisher
    
    weak var parent: MainViewModel?
    
    var tabSV: UIScrollView?
    
    var tabScrollProgress: CGFloat {
        let progress: CGFloat = normalizedCurrentTabOffset <= 1 ? normalizedCurrentTabOffset : 2 - normalizedCurrentTabOffset
        return max(0, min(2, progress))
    }
    
    var currentPageNumber: PageNumber {
        if normalizedCurrentTabOffset == 0 {
            return .one
        } else if normalizedCurrentTabOffset == 1 {
            return .two
        } else {
            return .three
        }
    }
    
    func scrollTo(page: PageNumber, animated: Bool) {
        let decodedOffset: CGFloat = page.rawValue * (parent?.screenWidth ?? .zero)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tabSV?.setContentOffset(
                .init(x: decodedOffset, y: 0),
                animated: animated
            )
            self.tabOffset = decodedOffset
            self.normalizedCurrentTabOffset = page.rawValue
        }
    }
    
    func onPageChange() {
        pageChange.toggle()
    }
}

extension BottomBarViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tabSV else { return }
        tabOffset = tabSV.contentOffset.x
        
        let screenWidth: CGFloat = parent?.screenWidth ?? .zero
        normalizedCurrentTabOffset = tabOffset/screenWidth
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onPageChange()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            onPageChange()
        }
    }
}

