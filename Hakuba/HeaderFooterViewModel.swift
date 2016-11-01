//
//  HeaderFooterViewModel.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

open class HeaderFooterViewModel {
    public enum `Type` {
        case header
        case footer
    }
    
    open let reuseIdentifier: String

    open internal(set) var section: Int = 0
    open internal(set) var type: Type = .header
    
    open var title: String?
    open var height: CGFloat = 44
    
    open var isHeader: Bool {
        return type == .header
    }
    
    open var isFooter: Bool {
        return type == .footer
    }
    
    public init<T>(view: T.Type) where T: HeaderFooterView, T: HeaderFooterViewType {
        self.reuseIdentifier = view.reuseIdentifier
    }
}
