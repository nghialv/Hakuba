//
//  HASection.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

protocol HASectionDelegate: class {
    func bumpMe(type: SectionBumpType, animation: HAAnimation)
}

public class HASection {
    weak var delegate: HASectionDelegate?
    public private(set) var cellmodels: [HACellModel] = []
    private let bumpTracker = HABumpTracker()
    
    internal(set) var index: Int = 0
    
    var changed: Bool {
        return bumpTracker.changed
    }
    
    public var header: HAHeaderFooterViewModel? {
        didSet {
            header?.section = index
            header?.isHeader = true
        }
    }
    
    public var footer: HAHeaderFooterViewModel? {
        didSet {
            footer?.section = index
            footer?.isHeader = false
        }
    }
    
    public subscript(index: Int) -> HACellModel? {
        get {
            return cellmodels.get(index)
        }
    }
    
    public init() {
    }
    
    func didReloadTableView() {
        bumpTracker.didBump()
    }
    
    func bump(animation: HAAnimation = .None) -> Self {
        let type = bumpTracker.getSectionBumpType(index)
        delegate?.bumpMe(type, animation: animation)
        bumpTracker.didBump()
        return self
    }
}

// MARK - Public methods

public extension HASection {
    
    // MARK - Reset
    
    func reset() -> Self {
        return reset([])
    }
    
    func reset(cellmodel: HACellModel) -> Self {
        return reset([cellmodel])
    }
    
    func reset(cellmodels: [HACellModel]) -> Self {
        setupCellmodels(cellmodels, indexFrom: 0)
        self.cellmodels = cellmodels
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    func append(cellmodel: HACellModel) -> Self {
        return append([cellmodel])
    }
    
    func append(cellmodels: [HACellModel]) -> Self {
        return insert(cellmodels, atIndex: count)
    }
    
    // MARK - Insert
    
    func insert(cellmodel: HACellModel, atIndex index: Int) -> Self {
        return insert([cellmodel], atIndex: index)
    }

    func insert(cellmodels: [HACellModel], atIndex index: Int) -> Self {
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
    
    func insertBeforeLast(viewmodel: HACellModel) -> Self {
        return insertBeforeLast([viewmodel])
    }
    
    func insertBeforeLast(viewmodels: [HACellModel]) -> Self {
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
        
        var remainCellmodels: [HACellModel] = []
        var i = 0
        
        for j in 0..<count {
            if let k = sortedIndexes.get(i) where k == j {
                i++
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
    
    func remove(cellmodel: HACellModel) -> Self {
        guard let index = cellmodels.indexOf(cellmodel) else {
            return self
        }
        
        return remove(index)
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

public extension HASection {
    var count: Int {
        return cellmodels.count
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var first: HACellModel? {
        return cellmodels.first
    }
    
    var last: HACellModel? {
        return cellmodels.last
    }
}

// MARK - Internal methods

extension HASection {
    func setup(index: Int, delegate: HASectionDelegate) {
        self.delegate = delegate
        self.index = index
        
        header?.section = index
        footer?.section = index
        setupCellmodels(cellmodels, indexFrom: 0)
    }
}

// MARK - Private methods

private extension HASection {
    func setupCellmodels(cellmodels: [HACellModel], var indexFrom start: Int) {
        guard let delegate = delegate as? HACellModelDelegate else {
            return
        }
        
        for cellmodel in cellmodels {
            let indexPath = NSIndexPath(forRow: start++, inSection: index)
            cellmodel.setup(indexPath, delegate: delegate)
        }
    }
}