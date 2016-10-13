//
//  ArrayExt.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

extension Array {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func hasIndex(_ index: Int) -> Bool {
        return indices ~= index
    }
    
    func getSafeIndex(_ index: Int) -> Int {
        let mIndex = Swift.max(0, index)
        return Swift.min(count, mIndex)
    }
    
    func getSafeRange(_ range: Range<Int>) -> CountableRange<Int>? {
        let start = Swift.max(0, range.lowerBound)
        let end = Swift.min(count, range.upperBound)
        return start <= end ? start..<end : nil
    }
    
    func get(_ index: Int) -> Element? {
        return hasIndex(index) ? self[index] : nil
    }
    
    mutating func append(_ newArray: Array) -> CountableRange<Int> {
        let range = count..<(count + newArray.count)
        self += newArray
        return range
    }
    
    mutating func insert(_ newArray: Array, atIndex index: Int) -> CountableRange<Int> {
        let mIndex = Swift.max(0, index)
        let start = Swift.min(count, mIndex)
        let end = start + newArray.count
        
        let left = self[0..<start]
        let right = self[start..<count]
        self = left + newArray + right
        return start..<end
    }
    
    mutating func move(fromIndex from: Int, toIndex to: Int) -> Bool {
        if !hasIndex(from) || !hasIndex(to) || from == to {
            return false
        }
        
        if let fromItem = get(from) {
            let _ = remove(from)
            insert(fromItem, at: to)
            return true
        }
        return false
    }
    
    mutating func remove(_ index: Int) -> CountableRange<Int>? {
        if !hasIndex(index) {
            return nil
        }
        self.remove(at: index)
        return index..<(index + 1)
    }
    
    mutating func remove(_ range: Range<Int>) -> CountableRange<Int>? {
        if let sr = getSafeRange(range) {
            removeSubrange(sr)
            return sr
        }
        return nil
    }
    
    mutating func remove<T: AnyObject> (_ element: T) {
        let anotherSelf = self
        
        removeAll(keepingCapacity: true)
        
        anotherSelf.each { (index: Int, current: Element) in
            if (current as! T) !== element {
                self.append(current)
            }
        }
    }
    
    mutating func removeLast() -> CountableRange<Int>? {
        return remove(count - 1)
    }
    
    func each(_ exe: (Int, Element) -> ()) {
        for (index, item) in enumerated() {
            exe(index, item)
        }
    }
}
