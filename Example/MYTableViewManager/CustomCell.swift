//
//  CustomCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCellModel : MYCellModel {
    let title: String
    
    init(title: String, selectionHandler: MYSelectionHandler) {
        self.title = title
        super.init(cellClass: CustomCell.self, height: 40, selectionHandler: selectionHandler)
    }
}

class CustomCell : MYTableViewCell {
    @IBOutlet weak var titleLabel: MYLabel!
    
    override func configureCell(cellModel: MYCellModel) {
        super.configureCell(cellModel)
        if let title = (cellModel as? CustomCellModel)?.title {
            titleLabel.text = title + "(\(cellModel.section),\(cellModel.row))"
        }
    }
}