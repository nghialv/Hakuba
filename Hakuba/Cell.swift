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
    func willDisplay(_ tableView: UITableView) {
    }
    
    func didEndDisplay(_ tableView: UITableView) {
    }
    
    func willSelect(_ tableView: UITableView, indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func didSelect(_ tableView: UITableView) {
    }
    
    func willDeselect(_ tableView: UITableView, indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func didDeselect(_ tableView: UITableView) {
    }
    
    func willBeginEditing(_ tableView: UITableView) {
    }
    
    func didEndEditing(_ tableView: UITableView) {
    }
    
    func didHighlight(_ tableView: UITableView) {
    }
    
    func didUnhighlight(_ tableView: UITableView) {
    }
}
