//
//  HACell.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

public class HACell: UITableViewCell {
    public private(set) weak var cellmodel: HACellModel?
    
    public func configureCell(cellmodel: HACellModel) {
        self.cellmodel = cellmodel
    }
}

// MARK - Cell events

public extension HACell {
    func willDisplay(tableView: UITableView) {
    }
    
    func willAppear(tableView: UITableView) {
    }
    
    func didDisappear(ableView: UITableView) {
    }
    
    func willSelect(tableView: UITableView) {
    }
    
    func didSelect(tableView: UITableView) {
    }
    
    func willDeselect(tableView: UITableView) {
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
