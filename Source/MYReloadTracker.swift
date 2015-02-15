//
//  MYReloadTracker.swift
//  MYTableViewManager
//
//  Created by Le VanNghia on 2/15/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

enum ReloadState {
    case Reset, Add, Remove, Begin
}

class MYReloadTracker {
    var state: ReloadState = .Begin
    private var addedIndexes: [Int] = []
    private var removedIndexes: [Int] = []
    
    init() {
        didFire()
    }
    
    func didReset() {
        state = .Reset
    }
    
    func didAdd(range: Range<Int>) {
        if state == .Reset || state == .Remove {
            state = .Reset
            return
        }
        for i in range {
            var newIndexes: [Int] = []
            if addedIndexes.indexOf(i) == nil {
                newIndexes.append(i)
            }
            addedIndexes += newIndexes
        }
        state = .Add
    }
    
    func didRemove(range: Range<Int>) {
        if state == .Reset || state == .Add {
            state = .Reset
            return
        }
        for i in range {
            var newIndexes: [Int] = []
            if removedIndexes.indexOf(i) == nil {
                newIndexes.append(i)
            }
            removedIndexes += newIndexes
        }
        state = .Remove
    }
    
    func didFire() {
        state = .Begin
        addedIndexes = []
        removedIndexes = []
    }
    
    func getIndexPaths(section: Int) -> [NSIndexPath] {
        switch state {
        case .Add:
            return addedIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        case .Remove:
            return removedIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        default:
            break
        }
        return []
    }
    
    func getSectionIndexSet() -> NSIndexSet {
        switch state {
        case .Add:
            if addedIndexes.count == 0 {
                return NSIndexSet()
            }
            let min = minElement(addedIndexes)
            let max = maxElement(addedIndexes)
            return NSIndexSet(indexesInRange: NSRange(min...max))
        case .Remove:
            if removedIndexes.count == 0 {
                return NSIndexSet()
            }
            let min = minElement(removedIndexes)
            let max = maxElement(removedIndexes)
            return NSIndexSet(indexesInRange: NSRange(min...max))
        default:
            return NSIndexSet()
        }
    }
}