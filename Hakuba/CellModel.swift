//
//  CellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

protocol CellModelDelegate: class {
    func bumpMe(type: ItemBumpType, animation: Animation)
    func getOffscreenCell(identifier: String) -> Cell
    func tableViewWidth() -> CGFloat
    func deselectCell(indexPath: NSIndexPath, animated: Bool)
}

public class CellModel {
    weak var delegate: CellModelDelegate?
    
    public let reuseIdentifier: String
    public internal(set) var indexPath = NSIndexPath(forRow: 0, inSection: 0)
    public var selectionHandler: SelectionHandler?

    public var selectable = true
    public var editable = false
    public var editingStyle: UITableViewCellEditingStyle = .None
    public var shouldHighlight = true
    
    public var height: CGFloat {
        get {
            return dynamicHeightEnabled ? calculateHeight() : estimatedHeight
        }
        set {
            estimatedHeight = newValue
        }
    }
    
    public var dynamicHeightEnabled: Bool = false {
        didSet {
            calculatedHeight = nil
        }
    }

    private var estimatedHeight: CGFloat = 0
    private var calculatedHeight: CGFloat?
    
    public init<T where T: Cell, T: CellType>(cell: T.Type, height: CGFloat = 44, selectionHandler: SelectionHandler? = nil) {
        self.reuseIdentifier = cell.reuseIdentifier
        self.estimatedHeight = height
        self.selectionHandler = selectionHandler
    }
    
    public func bump(animation: Animation = .None) -> Self {
        calculatedHeight = nil
        delegate?.bumpMe(ItemBumpType.Reload(indexPath), animation: animation)
        return self
    }
    
    public func deselect(animated: Bool) {
        delegate?.deselectCell(indexPath, animated: animated)
    }
}

// MARK - Internal methods

extension CellModel {
    func setup(indexPath: NSIndexPath, delegate: CellModelDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func didSelect(cell: Cell) {
        selectionHandler?(cell)
    }
}

// MARK - Private methods

private extension CellModel {
    func calculateHeight() -> CGFloat {
        if let height = calculatedHeight {
            return height
        }
        
        guard let cell = delegate?.getOffscreenCell(reuseIdentifier) else {
            return estimatedHeight
        }
        
        cell.configureCell(self)
       
        let width = delegate?.tableViewWidth() ?? UIScreen.mainScreen().bounds.width
        cell.bounds = CGRectMake(0, 0, width, cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let height = size.height + 1
        calculatedHeight = height
        
        return height
    }
}