//
//  CustomCellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/14/16.
//
//

import Foundation

class CustomCellModel: CellModel {
    let title: String
    
    init(title: String, selectionHandler: @escaping (Cell) -> ()) {
        self.title = title
        
        super.init(cell: CustomCell.self, selectionHandler: selectionHandler)
    }
}
