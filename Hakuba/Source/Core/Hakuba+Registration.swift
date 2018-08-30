//
//  Hakuba+Registration.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

public extension Hakuba {
    @discardableResult
    func registerCellByNib<T: Cell & CellType>(_ cellType: T.Type) -> Self {
        tableView?.registerCellByNib(cellType: cellType)
        return self
    }
    
    @discardableResult
    func registerCellsByNib<T: Cell & CellType>(_ cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCellByNib(cellType)
        }
        return self
    }
    
    @discardableResult
    func registerCell<T: Cell>(_ cellType: T.Type) -> Self {
        tableView?.registerCell(cellType: cellType)
        return self
    }
    
    @discardableResult
    func registerCells<T: Cell>(_ cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCell(cellType)
        }
        return self
    }
    
    @discardableResult
    func registerHeaderFooterByNib<T: HeaderFooterView & HeaderFooterViewType>(_ viewTypet: T.Type) -> Self {
        tableView?.registerHeaderFooterByNib(viewType: viewTypet)
        return self
    }
    
    @discardableResult
    func registerHeaderFooter<T: HeaderFooterView & HeaderFooterViewType>(_ viewTypet: T.Type) -> Self {
        tableView?.registerHeaderFooter(viewType: viewTypet)
        return self
    }
}
