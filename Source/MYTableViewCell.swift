//
//  MYTableViewCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYCellModel : MYViewModel {
    let identifier: String
    internal(set) var row: Int = 0
    internal(set) var section: Int = 0
    var indexPath: NSIndexPath {
        return NSIndexPath(forRow: row, inSection: section)
    }
    var calculatedHeight: CGFloat?
    
    public var editable = false
    public var dynamicHeightEnabled: Bool = false {
        didSet {
            calculatedHeight = nil
        }
    }
    
    public init(cell: MYTableViewCell.Type, height: CGFloat = 44, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = cell.reuseIdentifier ?? ""
        
        super.init(selectionHandler: selectionHandler)
        self.height = height
    }
    
    public func slide(animation: MYAnimation = .None) -> Self {
        delegate?.reloadView(row, section: section, animation: animation)
        return self
    }
}

public class MYTableViewCell : UITableViewCell, MYBaseViewProtocol {
    private weak var delegate: MYBaseViewDelegate?
    public internal(set) weak var cellModel: MYCellModel?
	
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
    
    public func configureCell(cellModel: MYCellModel) {
        self.cellModel = cellModel
        delegate = cellModel
        //unhighlight(false)
    }
   
    public func emitSelectedEvent(view: MYBaseViewProtocol) {
        delegate?.didSelect(view)
    }
    
    public func willAppear(data: MYCellModel, tableView: UITableView) {
    }
    
    public func didDisappear(data: MYCellModel, tableView: UITableView) {
    }
}