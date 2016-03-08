//
//  HAHeaderFooterViewModel.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HAHeaderFooterViewModel {
    let reuseIdentifier: String
    internal(set) var section: Int = 0
    internal(set) var isHeader = true
    
    public var isEnabled = true
    
    public init<T: HAHeaderFooterView>(view: T.Type, userData: AnyObject?, selectionHandler: HASelectionHandler? = nil) {
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
