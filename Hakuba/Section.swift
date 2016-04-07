//
//  Section.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

protocol SectionDelegate: class {
    func bumpMe(type: SectionBumpType, animation: Animation)
}

public class Section {
    weak var delegate: SectionDelegate?
    public private(set) var cellmodels: [CellModel] = []
    private let bumpTracker = BumpTracker()
    
    internal(set) var index: Int = 0
    
    var changed: Bool {
        return bumpTracker.changed
    }
    
    public var header: HeaderFooterViewModel? {
        didSet {
            header?.section = index
            header?.type = .Header
        }
    }
    
    public var footer: HeaderFooterViewModel? {
        didSet {
            footer?.section = index
            footer?.type = .Footer
        }
    }
    
    public subscript(index: Int) -> CellModel? {
        get {
            return cellmodels.get(index)
        }
    }
    
    public init() {
    }
    
    public func bump(animation: Animation = .None) -> Self {
        let type = bumpTracker.getSectionBumpType(index)
        delegate?.bumpMe(type, animation: animation)
        bumpTracker.didBump()
        return self
    }
}

// MARK - Public methods

public extension Section {
    
    // MARK - Reset
    
    func reset() -> Self {
        return reset([])
    }
    
    func reset(cellmodel: CellModel) -> Self {
        return reset([cellmodel])
    }
    
    func reset(cellmodels: [CellModel]) -> Self {
        setupCellmodels(cellmodels, indexFrom: 0)
        self.cellmodels = cellmodels
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    func append(cellmodel: CellModel) -> Self {
        return append([cellmodel])
    }
    
    func append(cellmodels: [CellModel]) -> Self {
        return insert(cellmodels, atIndex: count)
    }
    
    // MARK - Insert
    
    func insert(cellmodel: CellModel, atIndex index: Int) -> Self {
        return insert([cellmodel], atIndex: index)
    }

    func insert(cellmodels: [CellModel], atIndex index: Int) -> Self {
        guard cellmodels.isNotEmpty else {
            return self
        }
        
        let start = min(count, index)
        self.cellmodels.insert(cellmodels, atIndex: start)
        
        let affectedCellmodels = Array(self.cellmodels[start..<count])
        setupCellmodels(affectedCellmodels, indexFrom: start)
        
        let indexes = (index..<(index + cellmodels.count)).map { $0 }
        bumpTracker.didInsert(indexes)
        
        return self
    }
    
    func insertBeforeLast(viewmodel: CellModel) -> Self {
        return insertBeforeLast([viewmodel])
    }
    
    func insertBeforeLast(viewmodels: [CellModel]) -> Self {
        let index = max(cellmodels.count - 1, 0)
        return insert(viewmodels, atIndex: index)
    }
    
    // MARK - Remove
    
    func remove(index: Int) -> Self {
        return remove([index])
    }

    func remove(range: Range<Int>) -> Self {
        let indexes = range.map { $0 }
        return remove(indexes)
    }
    
    func remove(indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else {
            return self
        }
        
        let sortedIndexes = indexes
            .sort(<)
            .filter { $0 >= 0 && $0 < self.count }
        
        var remainCellmodels: [CellModel] = []
        var i = 0
        
        for j in 0..<count {
            if let k = sortedIndexes.get(i) where k == j {
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

    func removeLast() -> Self {
        let index = cellmodels.count - 1
        guard index >= 0 else {
            return self
        }
        
        return remove(index)
    }
    
    func remove(cellmodel: CellModel) -> Self {
        let index = cellmodels.indexOf { return  $0 === cellmodel }
        
        guard let i = index else {
            return self
        }
        
        return remove(i)
    }
    
    // MAKR - Move
    
    func move(from: Int, to: Int) -> Self {
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
    func setup(index: Int, delegate: SectionDelegate) {
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
    func setupCellmodels(cellmodels: [CellModel], indexFrom start: Int) {
        guard let delegate = delegate as? CellModelDelegate else {
            return
        }
        
        var start = start
        
        cellmodels.forEach { cellmodel in
            let indexPath = NSIndexPath(forRow: start, inSection: index)
            cellmodel.setup(indexPath, delegate: delegate)
            start += 1
        }
    }
}