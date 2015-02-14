//
//  MYSection.swift
//  MYTableViewManager
//
//  Created by Le VanNghia on 2/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

public class MYSection {
    var header: MYHeaderFooterViewModel?
    var footer: MYHeaderFooterViewModel?
    
    private var items: [MYCellViewModel] = []
    
    public subscript(index: Int) -> MYCellViewModel {
        get {
            return items[index]
        }
    }
}

public extension MYSection {
    // MARK - reset
    func reset() -> Self {
        items = []
        return self
    }
    
    func reset(viewmodel: MYCellViewModel) -> Self {
        return reset([viewmodel])
    }
    
    func reset(viewmodels: [MYCellViewModel]) -> Self {
        items = viewmodels
        return self
    }
    
    // MARK - apppend
    func append(viewmodel: MYCellViewModel) -> Self {
        return append([viewmodel])
    }
    
    func append(viewmodels: [MYCellViewModel]) -> Self {
        items += viewmodels
        return self
    }
    
    // MARK - insert
    func insert(viewmodel: MYCellViewModel, atIndex index: Int) -> Self {
        return insert([viewmodel], atIndex: index)
    }
    
    func insert(viewmodels: [MYCellViewModel], atIndex index: Int) -> Self {
        let range = items.insert(viewmodels, atIndex: index)
        // TODO : save inserted range
        return self
    }
    
    // MARK - remove
    func remove(index: Int) -> Self {
        if let ri = items.remove(index) {
            // TODO: save removed index
        }
        return self
    }
    
    func removeLast() -> Self {
        self.remove(items.count - 1)
        return self
    }
    
    func remove(range: Range<Int>) -> Self {
        if let r = items.remove(range) {
            // TODO : save removed range
        }
        return self
    }
    
    // MARK - fire
    func fire() -> Self {
        return self
    }
}

public extension MYSection {
    var count: Int {
        return items.count
    }
    
    var isEmpty: Bool {
        return items.count == 0
    }

    var first: MYCellViewModel? {
        return items.first
    }
    
    var last: MYCellViewModel? {
        return items.last
    }
}