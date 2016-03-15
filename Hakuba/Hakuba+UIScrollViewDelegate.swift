//
//  Hakuba+UIScrollViewDelegate.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

extension Hakuba {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
        
        if let indexPath = tableView?.indexPathsForVisibleRows?.first {
            let topSection = indexPath.section
            
            if currentTopSection != topSection {
                if let headerView = tableView?.headerViewForSection(currentTopSection) as? HeaderFooterView {
                    headerView.didChangeFloatingState(false, section: currentTopSection)
                }
                if let headerView = tableView?.headerViewForSection(topSection) as? HeaderFooterView {
                    headerView.didChangeFloatingState(true, section: topSection)
                }
                if currentTopSection > topSection {
                    willFloatingSection = topSection
                }
                currentTopSection = topSection
            }
        }
        
        if !loadmoreEnabled {
            return
        }
        
        let offset = scrollView.contentOffset
        let y = offset.y + scrollView.bounds.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        
        if y > h - loadmoreThreshold {
            loadmoreEnabled = false
            loadmoreHandler?()
        }
    }
    
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
