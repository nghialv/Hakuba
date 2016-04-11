//
//  BumpTracker.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

private enum UpdateState {
    case Begin
    case Reload
    case Insert([Int])
    case Move(Int, Int)
    case Remove([Int])
}

final class BumpTracker {
    private var state: UpdateState = .Begin
    
    var changed: Bool {
        if case .Begin = state {
            return false
        }
        return true
    }
    
    func didBump() {
        state = .Begin
    }
    
    func didReset() {
        state = .Reload
    }
    
    func didInsert(indexes: [Int]) {
        switch state {
        case .Begin:
            state = .Insert(indexes)
            
        default:
            state = .Reload
        }
    }
    
    func didMove(from: Int, to: Int) {
        switch state {
        case .Begin:
            state = .Move(from, to)
            
        default:
            state = .Reload
        }
    }
    
    func didRemove(indexes: [Int]) {
        switch state {
        case .Begin:
            state = .Remove(indexes)
            
        default:
            state = .Reload
        }
    }
    
    func getSectionBumpType(index: Int) -> SectionBumpType {
        let toIndexPath = { (row: Int) -> NSIndexPath in
            return NSIndexPath(forRow: row, inSection: index)
        }
        
        switch state {
        case .Insert(let indexes) where indexes.isNotEmpty:
            return .Insert(indexes.map(toIndexPath))
            
        case .Move(let from, let to):
            return .Move(toIndexPath(from), toIndexPath(to))
            
        case .Remove(let indexes) where indexes.isNotEmpty:
            return .Delete(indexes.map(toIndexPath))
            
        default:
            return .Reload(NSIndexSet(index: index))
        }
    }
    
    func getHakubaBumpType() -> HakubaBumpType {
        let toIndexSet = { (indexes: [Int]) -> NSIndexSet in
            let indexSet = NSMutableIndexSet()
            for index in indexes {
                indexSet.addIndex(index)
            }
            return indexSet
        }
        
        switch state {
        case .Insert(let indexes) where indexes.isNotEmpty:
            return .Insert(toIndexSet(indexes))
            
        case .Move(let from, let to):
            return .Move(from, to)
            
        case .Remove(let indexes) where indexes.isNotEmpty:
            return .Delete(toIndexSet(indexes))
            
        default:
            return .Reload
        }
    }
}