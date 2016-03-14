//
//  CustomCellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/14/16.
//
//

import Foundation

class CustomCellModel: HACellModel {
    let title: String
    
    init(title: String, selectionHandler: HASelectionHandler) {
        self.title = title
        super.init(cell: CustomCell.self, selectionHandler: selectionHandler)
    }
}
