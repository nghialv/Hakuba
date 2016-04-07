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
    
    func hasIndex(index: Int) -> Bool {
        return indices ~= index
    }
    
    func getSafeIndex(index: Int) -> Int {
        let mIndex = max(0, index)
        return min(count, mIndex)
    }
    
    func getSafeRange(range: Range<Int>) -> Range<Int>? {
        let start = max(0, range.startIndex)
        let end = min(count, range.endIndex)
        return start <= end ? start..<end : nil
    }
    
    func get(index: Int) -> Element? {
        return hasIndex(index) ? self[index] : nil
    }
    
    mutating func append(newArray: Array) -> Range<Int> {
        let range = count..<(count + newArray.count)
        self += newArray
        return range
    }
    
    mutating func insert(newArray: Array, atIndex index: Int) -> Range<Int> {
        let mIndex = max(0, index)
        let start = min(count, mIndex)
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
            remove(from)
            insert(fromItem, atIndex: to)
            return true
        }
        return false
    }
    
    mutating func remove(index: Int) -> Range<Int>? {
        if !hasIndex(index) {
            return nil
        }
        removeAtIndex(index)
        return index..<(index + 1)
    }
    
    mutating func remove(range: Range<Int>) -> Range<Int>? {
        if let sr = getSafeRange(range) {
            removeRange(sr)
            return sr
        }
        return nil
    }
    
    mutating func remove<T: AnyObject> (element: T) {
        let anotherSelf = self
        
        removeAll(keepCapacity: true)
        
        anotherSelf.each { (index: Int, current: Element) in
            if (current as! T) !== element {
                self.append(current)
            }
        }
    }
    
    mutating func removeLast() -> Range<Int>? {
        return remove(count - 1)
    }
    
    func each(exe: (Int, Element) -> ()) {
        for (index, item) in enumerate() {
            exe(index, item)
        }
    }
}