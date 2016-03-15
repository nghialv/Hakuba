//
//  HeaderFooterViewModel.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HeaderFooterViewModel {
    let reuseIdentifier: String
    internal(set) var section: Int = 0
    internal(set) var isHeader = true
    
    public var isEnabled = true
    public var height: CGFloat = 0
    
    public init<T: HeaderFooterView>(view: T.Type, userData: AnyObject?, selectionHandler: HASelectionHandler? = nil) {
        self.reuseIdentifier = view.reuseIdentifier
    }
    
    func bump() -> Self {
//        if isHeader {
//            delegate?.reloadHeader(section)
//        } else {
//            delegate?.reloadFooter(section)
//        }
        return self
    }
}
