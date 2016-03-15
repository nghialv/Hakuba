//
//  Hakuba+Registration.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

public extension Hakuba {
    func registerCellByNib<T where T: Cell, T: CellType>(cellType: T.Type) -> Self {
        tableView?.registerCellByNib(cellType)
        return self
    }
    
    func registerCellsByNib<T where T: Cell, T: CellType>(cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCellByNib(cellType)
        }
        return self
    }
    
    func registerCell<T: Cell>(cellType: T.Type) -> Self {
        tableView?.registerCell(cellType)
        return self
    }
    
    func registerCells<T: Cell>(cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCell(cellType)
        }
        return self
    }
    
    func registerHeaderFooterByNib<T where T: HeaderFooterView, T: HeaderFooterViewType>(t: T.Type) -> Self {
        tableView?.registerHeaderFooterByNib(t)
        return self
    }
    
    func registerHeaderFooter<T where T: HeaderFooterView, T: HeaderFooterViewType>(t: T.Type) -> Self {
        tableView?.registerHeaderFooter(t)
        return self
    }
}
