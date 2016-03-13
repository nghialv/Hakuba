//
//  HACellType.swift
//  Example
//
//  Created by Le VanNghia on 3/13/16.
//
//

import Foundation

public protocol HACellType {
    typealias CellModel
    
    var cellmodel: CellModel? { get }
}

public extension HACellType where Self: HACell {
    var cellmodel: CellModel? {
        return _cellmodel as? CellModel
    }
}
