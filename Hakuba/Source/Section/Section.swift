//
//  Section.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation
import UIKit

protocol SectionDelegate: class {
    func bumpMe(with type: SectionBumpType, animation: UITableView.RowAnimation)
}

open class Section {
    weak var delegate: SectionDelegate?
    open private(set) var cellmodels: [CellModel] = []
    private let bumpTracker = BumpTracker()
    
    internal(set) var index: Int = 0
    
    var isChanged: Bool {
        return bumpTracker.isChanged
    }
    
    open var header: HeaderFooterViewModel? {
        didSet {
            header?.section = index
            header?.type = .header
        }
    }
    
    open var footer: HeaderFooterViewModel? {
        didSet {
            footer?.section = index
            footer?.type = .footer
        }
    }
    
    open subscript(index: Int) -> CellModel? {
        return cellmodels.get(at: index)
    }
    
    public init() {}
    
    @discardableResult
    open func bump(_ animation: UITableView.RowAnimation = .none) -> Self {
        let type = bumpTracker.getSectionBumpType(at: index)
        delegate?.bumpMe(with: type, animation: animation)
        bumpTracker.didBump()
        return self
    }
}

// MARK - Public methods

public extension Section {
    
    // MARK - Reset
    
    @discardableResult
    func reset() -> Self {
        return reset([])
    }
    
    @discardableResult
    func reset(_ cellmodel: CellModel) -> Self {
        return reset([cellmodel])
    }
    
    @discardableResult
    func reset(_ cellmodels: [CellModel]) -> Self {
        setupCellmodels(cellmodels, start: 0)
        self.cellmodels = cellmodels
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    @discardableResult
    func append(_ cellmodel: CellModel) -> Self {
        return append([cellmodel])
    }
    
    @discardableResult
    func append(_ cellmodels: [CellModel]) -> Self {
        return insert(cellmodels, at: count)
    }
    
    // MARK - Insert
    
    @discardableResult
    func insert(_ cellmodel: CellModel, at index: Int) -> Self {
        return insert([cellmodel], at: index)
    }
    
    @discardableResult
    func insert(_ cellmodels: [CellModel], at index: Int) -> Self {
        guard cellmodels.isNotEmpty else { return self }
        
        let start = min(count, index)
        
        self.cellmodels.insert(cellmodels, at: start)
        let affectedCellmodels = Array(self.cellmodels[start..<count])
        
        setupCellmodels(affectedCellmodels, start: start)
        
        let indexes = (index..<(index + cellmodels.count)).map { $0 }
        bumpTracker.didInsert(indexes: indexes)
        
        return self
    }
    
    @discardableResult
    func insertBeforeLast(_ viewmodel: CellModel) -> Self {
        return insertBeforeLast([viewmodel])
    }
    
    @discardableResult
    func insertBeforeLast(_ viewmodels: [CellModel]) -> Self {
        let index = max(cellmodels.count - 1, 0)
        return insert(viewmodels, at: index)
    }
    
    // MARK - Remove
    
    @discardableResult
    func remove(at index: Int) -> Self {
        return remove(at: [index])
    }
    
    @discardableResult
    func remove(range: CountableRange<Int>) -> Self {
        return remove(at: range.map { $0 })
    }
    
    @discardableResult
    func remove(range: CountableClosedRange<Int>) -> Self {
        return remove(at: range.map { $0 })
    }
    
    @discardableResult
    func remove(at indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else { return self }
        
        let sortedIndexes = indexes
            .sorted(by: <)
            .filter { $0 >= 0 && $0 < count }
        
        var remainCellmodels: [CellModel] = []
        var i = 0
        
        for j in 0..<count {
            if let k = sortedIndexes.get(at: i), k == j {
                i += 1
            } else {
                remainCellmodels.append(cellmodels[j])
            }
        }
        
        cellmodels = remainCellmodels
        setupCellmodels(cellmodels, start: 0)
        
        bumpTracker.didRemove(indexes: sortedIndexes)
        
        return self
    }
    
    @discardableResult
    func removeLast() -> Self {
        let index = cellmodels.count - 1
        
        guard index >= 0 else { return self }
        
        return remove(at: [index])
    }
    
    @discardableResult
    func remove(_ cellmodel: CellModel) -> Self {
        guard let index = cellmodels.index(where: { $0 === cellmodel }) else { return self }
        
        return remove(at: index)
    }
    
    // MAKR - Move
    
    @discardableResult
    func move(from fromIndex: Int, to toIndex: Int) -> Self {
        cellmodels.move(from: toIndex, to: toIndex)
        setupCellmodels([cellmodels[fromIndex]], start: fromIndex)
        setupCellmodels([cellmodels[toIndex]], start: toIndex)
        
        bumpTracker.didMove(from: fromIndex, to: toIndex)
        return self
    }
}

// MARK - Utilities

public extension Section {
    var count: Int {
        return cellmodels.count
    }
    
    var isEmpty: Bool {
        return cellmodels.isEmpty
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var first: CellModel? {
        return cellmodels.first
    }
    
    var last: CellModel? {
        return cellmodels.last
    }
}

// MARK - Internal methods

extension Section {
    func setup(at index: Int, delegate: SectionDelegate) {
        self.delegate = delegate
        self.index = index
        
        header?.section = index
        footer?.section = index
        setupCellmodels(cellmodels, start: 0)
    }
    
    func didReloadTableView() {
        bumpTracker.didBump()
    }
}

// MARK - Private methods

private extension Section {
    func setupCellmodels(_ cellmodels: [CellModel], start index: Int) {
        guard let delegate = delegate as? CellModelDelegate else { return }
        
        var start = index
        
        cellmodels.forEach { cellmodel in
            let indexPath = IndexPath(row: start, section: self.index)
            cellmodel.setup(indexPath: indexPath, delegate: delegate)
            start += 1
        }
    }
}
