//
//  CustomCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCell: HACell, HACellType {
    typealias CellModel = CustomCellModel
    
    @IBOutlet weak var titleLabel: HALabel!
    
    override func configure() {
        guard let cellmodel = cellmodel else {
            return
        }
        
        titleLabel.text = cellmodel.title + "(\(cellmodel.indexPath.section),\(cellmodel.indexPath.row))"
    }
    
    override func willDisplay(tableView: UITableView) {
        super.willDisplay(tableView)
        
    }
}
