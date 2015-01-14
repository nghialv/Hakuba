//
//  CustomCell.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCell : MYTableViewCell {
    @IBOutlet weak var titleLabel: MYLabel!
    
    override func configureCell(data: MYTableViewCellData) {
        super.configureCell(data)
        if let title = data.userData as? String {
            titleLabel.text = title
        }
    }
}