//
//  CustomCell.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class CustomCell : MYTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func setData(data: MYTableViewCellData) {
        super.setData(data)
        if let title = data.userData as? String {
            titleLabel.text = title
        }
    }
}