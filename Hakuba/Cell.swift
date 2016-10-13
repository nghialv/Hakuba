//
//  Cell.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

open class Cell: UITableViewCell {
    weak var _cellmodel: CellModel?
    
    func configureCell(_ cellmodel: CellModel) {
        _cellmodel = cellmodel
        configure()
    }
    
    open func configure() {
    }
}

// MARK - Cell events

public extension Cell {
    open func willDisplay(_ tableView: UITableView) {
    }
    
    public func didEndDisplay(_ tableView: UITableView) {
    }
    
    public func willSelect(_ tableView: UITableView, indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    public func didSelect(_ tableView: UITableView) {
    }
    
    public func willDeselect(_ tableView: UITableView, indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    public func didDeselect(_ tableView: UITableView) {
    }
    
    public func willBeginEditing(_ tableView: UITableView) {
    }
    
    public func didEndEditing(_ tableView: UITableView) {
    }
    
    public func didHighlight(_ tableView: UITableView) {
    }
    
    public func didUnhighlight(_ tableView: UITableView) {
    }
}
