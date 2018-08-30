//
//  HeaderFooterViewType.swift
//  Example
//
//  Created by Le VanNghia on 3/15/16.
//
//

import Foundation

public protocol HeaderFooterViewType {
    associatedtype ViewModel
    
    var viewmodel: ViewModel? { get }
}

public extension HeaderFooterViewType where Self: HeaderFooterView {
    var viewmodel: ViewModel? {
        return _viewmodel as? ViewModel
    }
}
