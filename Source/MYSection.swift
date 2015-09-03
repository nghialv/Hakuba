//
//  MYSection.swift
//  Hakuba
//
//  Created by Le VanNghia on 2/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

protocol MYSectionDelegate : class {
    func reloadSections(index: Int, animation: MYAnimation)
    func insertRows(indexPaths: [NSIndexPath], animation: MYAnimation)
    func deleteRows(indexPaths: [NSIndexPath], animation: MYAnimation)
    
    func willAddCellViewModels(viewmodels: [MYCellModel])
}

public class MYSection {
    internal(set) var index: Int = 0 {
        didSet {
            header?.section = index
            footer?.section = index
            for item in items {
                item.section = index
            }
        }
    }
    weak var delegate: MYSectionDelegate?
    private var items: [MYCellModel] = []
    private let reloadTracker = MYReloadTracker()
    var isChanged: Bool {
        return reloadTracker.isChanged
    }
    
    public var header: MYHeaderFooterViewModel? {
        didSet {
            header?.section = index
            header?.isHeader = true
        }
    }
    public var footer: MYHeaderFooterViewModel? {
        didSet {
            footer?.section = index
            footer?.isHeader = false
        }
    }

    public subscript(index: Int) -> MYCellModel? {
        get {
            return items.my_hasIndex(index) ? items[index] : nil
        }
    }
    
    public init() {
    }
    
    func didReloadTableView() {
        reloadTracker.didFire(self.count)
    }
}

public extension MYSection {
    // MARK - reset
    func reset() -> Self {
        items = []
        reloadTracker.didReset()
        return self
    }
    
    func reset(viewmodel: MYCellModel) -> Self {
        return reset([viewmodel])
    }
    
    func reset(viewmodels: [MYCellModel]) -> Self {
        delegate?.willAddCellViewModels(viewmodels)
        items = viewmodels
        resetIndex(0, end: self.count-1)
        reloadTracker.didReset()
        return self
    }
    
    // MARK - apppend
    func append(viewmodel: MYCellModel) -> Self {
        return append([viewmodel])
    }
    
    func append(viewmodels: [MYCellModel]) -> Self {
        delegate?.willAddCellViewModels(viewmodels)
        let r = items.my_append(viewmodels)
        resetIndex(r.startIndex, end: self.count-1)
        reloadTracker.didAdd(r)
        return self
    }
    
    // MARK - insert
    func insert(viewmodel: MYCellModel, atIndex index: Int) -> Self {
        return insert([viewmodel], atIndex: index)
    }
    
    func insert(viewmodels: [MYCellModel], atIndex index: Int) -> Self {
        delegate?.willAddCellViewModels(viewmodels)
        let r = items.my_insert(viewmodels, atIndex: index)
        resetIndex(r.startIndex, end: self.count-1)
        reloadTracker.didAdd(r)
        return self
    }
   
    func insertBeforeLast(viewmodel: MYCellModel) -> Self {
        return insertBeforeLast([viewmodel])
    }
    
    func insertBeforeLast(viewmodels: [MYCellModel]) -> Self {
        let index = max(items.count - 1, 0)
        return insert(viewmodels, atIndex: index)
    }
    
    // MARK - remove
    func remove(index: Int) -> Self {
        if let r = items.my_remove(index) {
            resetIndex(r.startIndex, end: self.count-1)
            reloadTracker.didRemove(r)
        }
        return self
    }
    
    func removeLast() -> Self {
        self.remove(items.count - 1)
        return self
    }
    
    func remove(range: Range<Int>) -> Self {
        if let r = items.my_remove(range) {
            resetIndex(r.startIndex, end: self.count-1)
            reloadTracker.didRemove(r)
        }
        return self
    }
   
    func remove(cellmodel: MYCellModel) -> Self {
        if let index = items.indexOf(cellmodel) {
            return remove(index)
        }
        return self
    }
    
    // MARK - slide
    func slide(animation: MYAnimation = .None) -> Self {
        switch reloadTracker.state {
        case .Add:
            delegate?.insertRows(reloadTracker.getIndexPaths(index), animation: animation)
        case .Remove:
            delegate?.deleteRows(reloadTracker.getIndexPaths(index), animation: animation)
        default:
            delegate?.reloadSections(index, animation: animation)
            break
        }
        reloadTracker.didFire(self.count)
        return self
    }
    
    private func resetIndex(begin: Int, end: Int) {
        if begin > end {
            return
        }
        for i in (begin...end) {
            items[i].row = i
            items[i].section = index
        }
    }
}

public extension MYSection {
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.count == 0
    }

    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var first: MYCellModel? {
        return items.first
    }
    
    var last: MYCellModel? {
        return items.last
    }
}