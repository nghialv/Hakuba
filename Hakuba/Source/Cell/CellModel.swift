//
//  CellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

protocol CellModelDelegate: class {
    func bumpMe(with type: ItemBumpType, animation: UITableViewRowAnimation)
    func getOffscreenCell(by identifier: String) -> Cell
    func tableViewWidth() -> CGFloat
    func deselectCell(at indexPath: IndexPath, animated: Bool)
}

open class CellModel {
    weak var delegate: CellModelDelegate?
    
    open let reuseIdentifier: String
    open var height: CGFloat
    open var selectionHandler: SelectionHandler?
    
    open internal(set) var indexPath: IndexPath = .init(row: 0, section: 0)
    open var editable = false
    open var editingStyle: UITableViewCellEditingStyle = .none
    open var shouldHighlight = true
    
    public init<T: Cell & CellType>(cell: T.Type, height: CGFloat = UITableViewAutomaticDimension, selectionHandler: SelectionHandler? = nil) {
        self.reuseIdentifier = cell.reuseIdentifier
        self.height = height
        self.selectionHandler = selectionHandler
    }
    
    @discardableResult
    open func bump(_ animation: UITableViewRowAnimation = .none) -> Self {
        delegate?.bumpMe(with: .reload(indexPath), animation: animation)
        return self
    }
    
    open func deselect(_ animated: Bool) {
        delegate?.deselectCell(at: indexPath, animated: animated)
    }
}

// MARK - Internal methods

extension CellModel {
    func setup(indexPath: IndexPath, delegate: CellModelDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func didSelect(cell: Cell) {
        selectionHandler?(cell)
    }
}
