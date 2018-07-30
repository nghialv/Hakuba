//
//  HakubaDelegate.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

@objc public protocol HakubaDelegate : class {
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
    
    // Decelerating
    @objc optional func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    @objc optional func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidScrollToTop(_ scrollView: UIScrollView)
    
    // Draging
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    @objc optional func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}
