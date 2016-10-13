//
//  Hakuba+Registration.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

public extension Hakuba {
    func registerCellByNib<T>(_ cellType: T.Type) -> Self where T: Cell, T: CellType {
        tableView?.registerCellByNib(cellType)
        return self
    }
    
    func registerCellsByNib<T>(_ cellTypes: T.Type...) -> Self where T: Cell, T: CellType {
        for cellType in cellTypes {
            registerCellByNib(cellType)
        }
        return self
    }
    
    func registerCell<T: Cell>(_ cellType: T.Type) -> Self {
        tableView?.registerCell(cellType)
        return self
    }
    
    func registerCells<T: Cell>(_ cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCell(cellType)
        }
        return self
    }
    
    func registerHeaderFooterByNib<T>(_ t: T.Type) -> Self where T: HeaderFooterView, T: HeaderFooterViewType {
        tableView?.registerHeaderFooterByNib(t)
        return self
    }
    
    func registerHeaderFooter<T>(_ t: T.Type) -> Self where T: HeaderFooterView, T: HeaderFooterViewType {
        tableView?.registerHeaderFooter(t)
        return self
    }
}
