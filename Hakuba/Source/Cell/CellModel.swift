//
//  CellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

protocol CellModelDelegate: class {
    func bumpMe(with type: ItemBumpType, animation: UITableView.RowAnimation)
    func getOffscreenCell(by identifier: String) -> Cell
    func tableViewWidth() -> CGFloat
    func deselectCell(at indexPath: IndexPath, animated: Bool)
}

open class CellModel {
    weak var delegate: CellModelDelegate?
    
    open let reuseIdentifier: String
    open var height: CGFloat
    open var selectionHandler: ((Cell) -> Void)?
    
    open internal(set) var indexPath: IndexPath = .init(row: 0, section: 0)
    open var editable = false
    open var editingStyle: UITableViewCell.EditingStyle = .none
    open var shouldHighlight = true
    
    public init<T: Cell & CellType>(cell: T.Type, height: CGFloat = UITableView.automaticDimension, selectionHandler: ((Cell) -> Void)? = nil) {
        self.reuseIdentifier = cell.reuseIdentifier
        self.height = height
        self.selectionHandler = selectionHandler
    }
    
    @discardableResult
    open func bump(_ animation: UITableView.RowAnimation = .none) -> Self {
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
