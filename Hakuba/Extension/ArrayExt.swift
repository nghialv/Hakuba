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
    
    func hasIndex(at index: Int) -> Bool {
        return indices ~= index
    }
    
    func getSafeIndex(at index: Int) -> Int {
        let mIndex = Swift.max(0, index)
        return Swift.min(count, mIndex)
    }
    
    func getSafeRange(range: Range<Int>) -> Range<Int>? {
        let start = Swift.max(0, range.lowerBound)
        let end = Swift.min(count, range.upperBound)
        return start <= end ? start..<end : nil
    }
    
    func get(at index: Int) -> Element? {
        return hasIndex(at: index) ? self[index] : nil
    }
    
    @discardableResult
    mutating func append(_ newArray: Array) -> Range<Int> {
        let range = count..<(count + newArray.count)
        self += newArray
        return .init(range)
    }
    
    @discardableResult
    mutating func insert(_ newArray: Array, at index: Int) -> Range<Int> {
        let mIndex = Swift.max(0, index)
        let start = Swift.min(count, mIndex)
        let end = start + newArray.count
        
        let left = self[0..<start]
        let right = self[start..<count]
        self = left + newArray + right
        return start..<end
    }
    
    @discardableResult
    mutating func move(from fromIndex: Int, to toIndex: Int) -> Bool {
        if !hasIndex(at: fromIndex) || !hasIndex(at: toIndex) || fromIndex == toIndex {
            return false
        }
        
        if let fromItem = get(at: fromIndex) {
            remove(fromIndex)
            insert(fromItem, at: toIndex)
            return true
        }
        return false
    }
    
    @discardableResult
    mutating func remove(_ index: Int) -> Range<Int>? {
        if !hasIndex(at: index) {
            return nil
        }
        remove(at: index)
        return .init(index..<(index + 1))
    }
    
    @discardableResult
    mutating func remove(range: Range<Int>) -> Range<Int>? {
        if let sr = getSafeRange(range: range) {
            return remove(range: sr)
        }
        return nil
    }
    
    mutating func remove<T: AnyObject> (element: T) {
        let anotherSelf = self
        
        removeAll(keepingCapacity: true)
        
        anotherSelf.each { (index: Int, current: Element) in
            if (current as! T) !== element {
                self.append(current)
            }
        }
    }
    
    @discardableResult
    mutating func removeLast() -> Range<Int>? {
        return remove(count - 1)
    }
    
    func each(exe: (Int, Element) -> ()) {
        for (index, item) in enumerated() {
            exe(index, item)
        }
    }
}
