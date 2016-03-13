//
//  Hakuba+Registration.swift
//  Example
//
//  Created by Le VanNghia on 3/7/16.
//
//

import UIKit

public extension Hakuba {
    func registerCellByNib<T where T: HACell, T: HACellType>(cellType: T.Type) -> Self {
        tableView?.registerCellByNib(cellType)
        return self
    }
    
    func registerCellsByNib<T where T: HACell, T: HACellType>(cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCellByNib(cellType)
        }
        return self
    }
    
    func registerCell<T: HACell>(cellType: T.Type) -> Self {
        tableView?.registerCell(cellType)
        return self
    }
    
    func registerCells<T: HACell>(cellTypes: T.Type...) -> Self {
        for cellType in cellTypes {
            registerCell(cellType)
        }
        return self
    }
    
    func registerHeaderFooterByNib<T: UITableViewHeaderFooterView>(t: T.Type) -> Self {
        tableView?.registerHeaderFooterByNib(t)
        return self
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(t: T.Type) -> Self {
        tableView?.registerHeaderFooter(t)
        return self
    }
}
