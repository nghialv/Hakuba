//
//  CustomCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCellModel: HACellModel {
    let title: String
    
    init(title: String, selectionHandler: HASelectionHandler) {
        self.title = title
        super.init(cell: CustomCell.self, height: 40, selectionHandler: selectionHandler)
    }
}

class CustomCell: HACell, HACellType {
    typealias CellModel = CustomCellModel
    
    @IBOutlet weak var titleLabel: HALabel!
    
    override func configure() {
        guard let cellmodel = cellmodel else {
            return
        }
        
        titleLabel.text = cellmodel.title + "(\(cellmodel.indexPath.section),\(cellmodel.indexPath.row))"
    }
}
