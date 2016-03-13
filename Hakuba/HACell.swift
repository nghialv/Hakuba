//
//  HACell.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

public class HACell: UITableViewCell {
    weak var _cellmodel: HACellModel?
    
    func configureCell(cellmodel: HACellModel) {
        _cellmodel = cellmodel
        configure()
    }
    
    public func configure() {
    }
}

// MARK - Cell events

public extension HACell {
    func willDisplay(tableView: UITableView) {
    }
    
    func didEndDisplay(tableView: UITableView) {
    }
    
    func willSelect(tableView: UITableView, indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didSelect(tableView: UITableView) {
    }
    
    func willDeselect(tableView: UITableView, indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func didDeselect(tableView: UITableView) {
    }
    
    func willBeginEditing(tableView: UITableView) {
    }
    
    func didEndEditing(tableView: UITableView) {
    }
    
    func didHighlight(tableView: UITableView) {
    }
    
    func didUnhighlight(tableView: UITableView) {
    }
}
