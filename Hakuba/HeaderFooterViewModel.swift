//
//  HeaderFooterViewModel.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HeaderFooterViewModel {
    public enum Type {
        case Header
        case Footer
    }
    
    public let reuseIdentifier: String

    public internal(set) var section: Int = 0
    public internal(set) var type: Type = .Header
    
    public var title: String?
    public var height: CGFloat = 44
    
    public var isHeader: Bool {
        return type == .Header
    }
    
    public var isFooter: Bool {
        return type == .Footer
    }
    
    public init<T where T: HeaderFooterView, T: HeaderFooterViewType>(view: T.Type) {
        self.reuseIdentifier = view.reuseIdentifier
    }
}
