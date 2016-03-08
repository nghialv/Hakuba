//
//  HACellModel.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

protocol HACellModelDelegate: class {
    func bumpMe(type: ItemBumpType)
    func getOffscreenCell(identifier: String) -> HACell
    func tableViewWidth() -> CGFloat
}

public class HACellModel: NSObject {
    weak var delegate: HACellModelDelegate?
    
    public let reuseIdentifier: String
    public internal(set) var indexPath = NSIndexPath(forRow: 0, inSection: 0)
    public var selectionHandler: HASelectionHandler?
    public var deselectionHandler: HADeselectionHandler?

    public var selectable = true
    public var editable = false

    public var height: CGFloat {
        get {
            if dynamicHeightEnabled {
                return calculateHeight()
            } else {
                return estimatedHeight
            }
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
    
    public init<T: HACell>(cell: T.Type, height: CGFloat = 44, selectionHandler: HASelectionHandler? = nil) {
        self.reuseIdentifier = cell.reuseIdentifier
        self.estimatedHeight = height
        self.selectionHandler = selectionHandler
    }
    
    public func bump(animation: HAAnimation = .None) -> Self {
        calculatedHeight = nil
        delegate?.bumpMe(ItemBumpType.Reload(indexPath, animation))
        return self
    }
    
    public func deselect(animated: Bool) {
        //delegate?.deselectRow(indexPath, animated: animated)
    }
}

// MARK - Internal methods

extension HACellModel {
    func setup(indexPath: NSIndexPath, delegate: HACellModelDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }
    
    func didSelect(cell: HACell) {
        
    }
}

// MARK - Private methods

private extension HACellModel {
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
        return size.height + 1.0
    }
}