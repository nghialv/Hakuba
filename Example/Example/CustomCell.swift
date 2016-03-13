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

class CustomCell: HACell {
    @IBOutlet weak var titleLabel: HALabel!
    
    override func configureCell(cellmodel: HACellModel) {
        super.configureCell(cellmodel)
        
        guard let cellmodel = cellmodel as? CustomCellModel else {
            return
        }
        
        titleLabel.text = cellmodel.title + "(\(cellmodel.indexPath.section),\(cellmodel.indexPath.row))"
    }
}