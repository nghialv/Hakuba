//
//  CustomCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCell: Cell, CellType {
    typealias CellModel = CustomCellModel
    
    @IBOutlet weak var titleLabel: Label!
    
    override func configure() {
        guard let cellmodel = cellmodel else {
            return
        }
        
        titleLabel.text = cellmodel.title + "(\(cellmodel.indexPath.section),\(cellmodel.indexPath.row))"
    }
    
    override func willDisplay(_ tableView: UITableView) {
        super.willDisplay(tableView)
        
    }
}
