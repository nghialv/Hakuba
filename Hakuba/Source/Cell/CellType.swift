//
//  CellType.swift
//  Example
//
//  Created by Le VanNghia on 3/13/16.
//
//

import Foundation

public protocol CellType {
    associatedtype CellModel
    
    var cellmodel: CellModel? { get }
}

public extension CellType where Self: Cell {
    var cellmodel: CellModel? {
        return _cellmodel as? CellModel
    }
}
