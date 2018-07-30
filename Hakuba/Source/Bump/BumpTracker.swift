//
//  BumpTracker.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

private enum UpdateState: Equatable {
    case begin
    case reload
    case insert(indexes: [Int])
    case move(from: Int, to: Int)
    case remove(indexes: [Int])
}

final class BumpTracker {
    private var state: UpdateState = .begin
    
    var isChanged: Bool {
        return state != .begin
    }
    
    func didBump() {
        state = .begin
    }
    
    func didReset() {
        state = .reload
    }
    
    func didInsert(indexes: [Int]) {
        switch state {
        case .begin:
            state = .insert(indexes: indexes)
            
        default:
            state = .reload
        }
    }
    
    func didMove(from: Int, to: Int) {
        switch state {
        case .begin:
            state = .move(from: from, to: to)
            
        default:
            state = .reload
        }
    }
    
    func didRemove(indexes: [Int]) {
        switch state {
        case .begin:
            state = .remove(indexes: indexes)
            
        default:
            state = .reload
        }
    }
    
    func getSectionBumpType(at index: Int) -> SectionBumpType {
        let indexPath = { (row: Int) -> IndexPath in
            return .init(row: row, section: index)
        }
        
        switch state {
        case .insert(let indexes) where indexes.isNotEmpty:
            return .insert(indexes.map(indexPath))
            
        case .move(let from, let to):
            return .move(indexPath(from), indexPath(to))
            
        case .remove(let indexes) where indexes.isNotEmpty:
            return .delete(indexes.map(indexPath))
            
        default:
            return .reload(.init(integer: index))
        }
    }
    
    func getHakubaBumpType() -> HakubaBumpType {
        let indexSet = { (indexes: [Int]) -> IndexSet in
            let indexSet = NSMutableIndexSet()
            for index in indexes {
                indexSet.add(index)
            }
            return indexSet as IndexSet
        }
        
        switch state {
        case .insert(let indexes) where indexes.isNotEmpty:
            return .insert(indexSet(indexes))
            
        case .move(let from, let to):
            return .move(from, to)
            
        case .remove(let indexes) where indexes.isNotEmpty:
            return .delete(indexSet(indexes))
            
        default:
            return .reload
        }
    }
}
