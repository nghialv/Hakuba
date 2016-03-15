//
//  HakubaDelegate.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

@objc public protocol HakubaDelegate : class {
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    
    // Decelerating
    optional func scrollViewWillBeginDecelerating(scrollView: UIScrollView)
    optional func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    
    optional func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView)
    optional func scrollViewDidScrollToTop(scrollView: UIScrollView)
    
    // Draging
    optional func scrollViewWillBeginDragging(scrollView: UIScrollView)
    optional func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    optional func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
}
