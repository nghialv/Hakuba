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
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public func setup() {
    }
    
    public func configureCell(cellModel: HACellModel) {
        self.cellmodel = cellModel
    }
    
    public func willAppear(data: HACellModel, tableView: UITableView) {
    }
    
    public func didDisappear(data: HACellModel, tableView: UITableView) {
    }
}
