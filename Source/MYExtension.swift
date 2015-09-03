//
//  StringExtension.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation
import UIKit

func classNameOf(aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
}

// MARK - UITableViewCell

extension UITableViewCell {
    static var nibName: String {
        return classNameOf(self)
    }
    
    static var reuseIdentifier: String {
        return classNameOf(self)
    }
}

// MARK - UITableViewHeaderFooterView

extension UITableViewHeaderFooterView {
    static var nibName: String {
        return classNameOf(self)
    }
    
    static var reuseIdentifier: String {
        return classNameOf(self)
    }
}

// MARK - UITableView

extension UITableView {
    func registerNibForCellClass<T: UITableViewCell>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        registerNib(nib, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerCellClass<T: UITableViewCell>(t: T.Type) {
        registerClass(t, forCellReuseIdentifier: t.reuseIdentifier)
    }
   
    func registerNibForHeaderFooterClass<T: UITableViewHeaderFooterView>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        registerNib(nib, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerHeaderFooterClass<T: UITableViewHeaderFooterView>(t: T.Type) {
        registerClass(t, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(t: T.Type, forIndexPath indexPath: NSIndexPath) -> T {
        return dequeueReusableCellWithIdentifier(t.reuseIdentifier, forIndexPath: indexPath) as! T
    }
}

// MARK - NSRange

extension NSRange {
    init(range: Range<Int>) {
        self.location = range.startIndex
        self.length = range.endIndex - range.startIndex
    }
}

// MARK - Array

extension Array {
    func my_hasIndex(index: Int) -> Bool {
        return index >= 0 && index < count
    }
    
    func my_getSafeIndex(index: Int) -> Int {
        let mIndex = max(0, index)
        return min(count, mIndex)
    }
	
    func my_getSafeRange(range: Range<Int>) -> Range<Int>? {
        let start = max(0, range.startIndex)
        let end = min(count, range.endIndex)
        return start <= end ? Range<Int>(start: start, end: end) : nil
    }
    
    func my_get(index: Int) -> Element? {
        return my_hasIndex(index) ? self[index] : nil
    }
   
    mutating func my_append(newArray: Array) -> Range<Int> {
        let range = Range<Int>(start: count, end: count + newArray.count)
        self += newArray
        return range
    }
    
    mutating func my_insert(newArray: Array, atIndex index: Int) -> Range<Int> {
        let mIndex = max(0, index)
        let start = min(count, mIndex)
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
        for (index, item) in enumerate() {
            exe(index, item)
        }
    }
}