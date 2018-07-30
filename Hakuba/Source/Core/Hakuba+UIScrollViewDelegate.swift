//
//  Hakuba+UIScrollViewDelegate.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

extension Hakuba {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
        
        if let topSection = tableView?.indexPathsForVisibleRows?.first?.section, currentTopSection != topSection {
            if let headerView = tableView?.headerView(forSection: currentTopSection) as? HeaderFooterView {
                headerView.didChangeFloatingState(false, section: currentTopSection)
            }
            
            if let headerView = tableView?.headerView(forSection: topSection) as? HeaderFooterView {
                headerView.didChangeFloatingState(true, section: topSection)
            }
            
            if currentTopSection > topSection {
                willFloatingSection = topSection
            }
            
            currentTopSection = topSection
        }
        
        guard loadmoreEnabled else { return }
        
        let offset = scrollView.contentOffset
        let y = offset.y + scrollView.bounds.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        
        if y > h - loadmoreThreshold {
            loadmoreEnabled = false
            loadmoreHandler?()
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}
