//
//  CellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

protocol CellModelDelegate: class {
    func bumpMe(_ type: ItemBumpType, animation: Animation)
    func getOffscreenCell(_ identifier: String) -> Cell
    func tableViewWidth() -> CGFloat
    func deselectCell(_ indexPath: IndexPath, animated: Bool)
}

open class CellModel {
    weak var delegate: CellModelDelegate?
    
    open let reuseIdentifier: String
    open internal(set) var indexPath = IndexPath(row: 0, section: 0)
    open var selectionHandler: SelectionHandler?

    open var editable = false
    open var editingStyle: UITableViewCellEditingStyle = .none
    open var shouldHighlight = true
    
    open var height: CGFloat {
        get {
            return dynamicHeightEnabled ? calculateHeight() : estimatedHeight
        }
        set {
            estimatedHeight = newValue
        }
    }
    
    open var dynamicHeightEnabled: Bool = false {
        didSet {
            calculatedHeight = nil
        }
    }

    fileprivate var estimatedHeight: CGFloat = 0
    fileprivate var calculatedHeight: CGFloat?
    
    public init<T>(cell: T.Type, height: CGFloat = 44, selectionHandler: SelectionHandler? = nil) where T: Cell, T: CellType {
        self.reuseIdentifier = cell.reuseIdentifier
        self.estimatedHeight = height
        self.selectionHandler = selectionHandler
    }
    
    open func bump(_ animation: Animation = .none) -> Self {
        calculatedHeight = nil
        delegate?.bumpMe(ItemBumpType.reload(indexPath), animation: animation)
        return self
    }
    
    open func deselect(_ animated: Bool) {
        delegate?.deselectCell(indexPath, animated: animated)
    }
}

// MARK - Internal methods

extension CellModel {
    func setup(_ indexPath: IndexPath, delegate: CellModelDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func didSelect(_ cell: Cell) {
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
       
        let width = delegate?.tableViewWidth() ?? UIScreen.main.bounds.width
        cell.bounds = CGRect(x: 0, y: 0, width: width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let height = size.height + 1
        calculatedHeight = height
        
        return height
    }
}
