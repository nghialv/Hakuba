//
//  StringExtension.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

extension String {
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
    }
}

extension NSRange {
    init(range: Range<Int>) {
        self.location = range.startIndex
        self.length = range.endIndex - range.startIndex
    }
}

extension Array {
    func my_hasIndex(index: Int) -> Bool {
        return index >= 0 && index < count
    }
    
    func my_getSafeIndex(index: Int) -> Int {
        return min(count, max(0, index))
    }
   
    func my_indexOf<T: Equatable>(item: T) -> Int? {
        if item is Element {
            return find(unsafeBitCast(self, [T].self), item)
        }
        return nil
    }
    
    func my_getSafeRange(range: Range<Int>) -> Range<Int>? {
        let start = max(0, range.startIndex)
        let end = min(count, range.endIndex)
        return start <= end ? Range<Int>(start: start, end: end) : nil
    }
    
    func my_get(index: Int) -> T? {
        return my_hasIndex(index) ? self[index] : nil
    }
   
    mutating func my_append(newArray: Array) -> Range<Int> {
        let range = Range<Int>(start: count, end: count + newArray.count)
        self += newArray
        return range
    }
    
    mutating func my_insert(newArray: Array, atIndex index: Int) -> Range<Int> {
        let start = min(count, max(0, index))
        let end = start + newArray.count
        
        let left = self[0..<start]
        let right = self[start..<count]
        self = left + newArray + right
        return Range<Int>(start: start, end: end)
    }
    
    mutating func my_remove(index: Int) -> Range<Int>? {
        if !my_hasIndex(index) {
            return nil
        }
        self.removeAtIndex(index)
        return Range<Int>(start: index, end: index + 1)
    }
    
    mutating func my_remove(range: Range<Int>) -> Range<Int>? {
        if let sr = my_getSafeRange(range) {
            self.removeRange(sr)
            return sr
        }
        return nil
    }
    
    mutating func my_removeLast() -> Range<Int>? {
        return self.my_remove(count - 1)
    }
    
    func my_each(exe: (Int, Element) -> ()) {
        for (index, item) in enumerate(self) {
            exe(index, item)
        }
    }
}