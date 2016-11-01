//
//  Section.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

protocol SectionDelegate: class {
    func bumpMe(_ type: SectionBumpType, animation: Animation)
}

open class Section {
    weak var delegate: SectionDelegate?
    open fileprivate(set) var cellmodels: [CellModel] = []
    fileprivate let bumpTracker = BumpTracker()
    
    internal(set) var index: Int = 0
    
    var changed: Bool {
        return bumpTracker.changed
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
        get {
            return cellmodels.get(index)
        }
    }
    
    public init() {
    }
    
    @discardableResult open func bump(_ animation: Animation = .none) -> Self {
        let type = bumpTracker.getSectionBumpType(index)
        delegate?.bumpMe(type, animation: animation)
        bumpTracker.didBump()
        return self
    }
}

// MARK - Public methods

public extension Section {
    
    // MARK - Reset
    
    @discardableResult func reset() -> Self {
        return reset([])
    }
    
    @discardableResult func reset(_ cellmodel: CellModel) -> Self {
        return reset([cellmodel])
    }
    
    @discardableResult func reset(_ cellmodels: [CellModel]) -> Self {
        setupCellmodels(cellmodels, indexFrom: 0)
        self.cellmodels = cellmodels
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    @discardableResult func append(_ cellmodel: CellModel) -> Self {
        return append([cellmodel])
    }
    
    @discardableResult func append(_ cellmodels: [CellModel]) -> Self {
        return insert(cellmodels, atIndex: count)
    }
    
    // MARK - Insert
    
    @discardableResult func insert(_ cellmodel: CellModel, atIndex index: Int) -> Self {
        return insert([cellmodel], atIndex: index)
    }

    @discardableResult func insert(_ cellmodels: [CellModel], atIndex index: Int) -> Self {
        guard cellmodels.isNotEmpty else {
            return self
        }
        
        let start = min(count, index)
        let _ = self.cellmodels.insert(cellmodels, atIndex: start)
        
        let affectedCellmodels = Array(self.cellmodels[start..<count])
        setupCellmodels(affectedCellmodels, indexFrom: start)
        
        let indexes = (index..<(index + cellmodels.count)).map { $0 }
        bumpTracker.didInsert(indexes)
        
        return self
    }
    
    @discardableResult func insertBeforeLast(_ viewmodel: CellModel) -> Self {
        return insertBeforeLast([viewmodel])
    }
    
    @discardableResult func insertBeforeLast(_ viewmodels: [CellModel]) -> Self {
        let index = max(cellmodels.count - 1, 0)
        return insert(viewmodels, atIndex: index)
    }
    
    // MARK - Remove
    
    @discardableResult func remove(_ index: Int) -> Self {
        return remove([index])
    }
    
    @discardableResult func remove(_ range: CountableRange<Int>) -> Self {
        let indexes = [Int](range)
        return remove(indexes)
    }
    
    @discardableResult func remove(_ range: CountableClosedRange<Int>) -> Self {
        let indexes = [Int](range)
        return remove(indexes)
    }
    
    @discardableResult func remove(_ indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else {
            return self
        }
        
        let sortedIndexes = indexes
            .sorted(by: <)
            .filter { $0 >= 0 && $0 < self.count }
        
        var remainCellmodels: [CellModel] = []
        var i = 0
        
        for j in 0..<count {
            if let k = sortedIndexes.get(i), k == j {
                i += 1
            } else {
                remainCellmodels.append(cellmodels[j])
            }
        }
        
        cellmodels = remainCellmodels
        setupCellmodels(cellmodels, indexFrom: 0)
        
        bumpTracker.didRemove(sortedIndexes)
        
        return self
    }

    @discardableResult func removeLast() -> Self {
        let index = cellmodels.count - 1
        guard index >= 0 else {
            return self
        }
        
        return remove(index)
    }
    
    @discardableResult func remove(_ cellmodel: CellModel) -> Self {
        let index = cellmodels.index { return  $0 === cellmodel }
        
        guard let i = index else {
            return self
        }
        
        return remove(i)
    }
    
    // MAKR - Move
    
    @discardableResult func move(_ from: Int, to: Int) -> Self {
        cellmodels.move(fromIndex: from, toIndex: to)
        setupCellmodels([cellmodels[from]], indexFrom: from)
        setupCellmodels([cellmodels[to]], indexFrom: to)
        
        bumpTracker.didMove(from, to: to)
        return self
    }
}

// MARK - Utilities

public extension Section {
    var count: Int {
        return cellmodels.count
    }
    
    var isEmpty: Bool {
        return count == 0
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
    func setup(_ index: Int, delegate: SectionDelegate) {
        self.delegate = delegate
        self.index = index
        
        header?.section = index
        footer?.section = index
        setupCellmodels(cellmodels, indexFrom: 0)
    }
    
    func didReloadTableView() {
        bumpTracker.didBump()
    }
}

// MARK - Private methods

private extension Section {
    func setupCellmodels(_ cellmodels: [CellModel], indexFrom start: Int) {
        guard let delegate = delegate as? CellModelDelegate else {
            return
        }
        
        var start = start
        
        cellmodels.forEach { cellmodel in
            let indexPath = IndexPath(row: start, section: index)
            cellmodel.setup(indexPath, delegate: delegate)
            start += 1
        }
    }
}
