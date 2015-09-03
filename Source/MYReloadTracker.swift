//
//  MYReloadTracker.swift
//  Hakuba
//
//  Created by Le VanNghia on 2/15/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

enum ReloadState {
    case Reset
    case Add
    case Remove
    case Begin
}

class MYReloadTracker {
    var state: ReloadState = .Begin
    private var originalIndexes: [Int] = []
    private var removedIndexes: [Int] = []
    var isChanged: Bool {
        return state != .Begin
    }
    
    init() {
        didFire(0)
    }
    
    func didReset() {
        state = .Reset
    }
    
    func didAdd(range: Range<Int>) {
        if state == .Reset || state == .Remove {
            state = .Reset
            return
        }
        let ind = range.map { _ -> Int in -1 }
        originalIndexes.my_insert(ind, atIndex: range.startIndex)
        state = .Add
    }
    
    func didRemove(range: Range<Int>) {
        if state == .Reset || state == .Add {
            state = .Reset
            return
        }
        let ri = originalIndexes[range]
        originalIndexes.my_remove(range)
        for i in ri {
            var newIndexes: [Int] = []
            if removedIndexes.indexOf(i) == nil {
                newIndexes.append(i)
            }
            removedIndexes += newIndexes
        }
        state = .Remove
    }
    
    func didFire(count: Int) {
        state = .Begin
        originalIndexes = (0..<count).map { $0 }
        removedIndexes = []
    }
    
    func getIndexPaths(section: Int) -> [NSIndexPath] {
        switch state {
        case .Add:
            var addedIndexes: [Int] = []
            originalIndexes.my_each { i, value in
                if value == -1 {
                    addedIndexes.append(i)
                }
            }
            return addedIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        case .Remove:
            return removedIndexes.map { NSIndexPath(forRow: $0, inSection: section) }
        default:
            break
        }
        return []
    }
}