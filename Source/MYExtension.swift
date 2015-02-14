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

extension Array {
    mutating func insert(newArray: Array, atIndex index: Int) {
        let left = self[0..<max(0, index)]
        let right = index > count ? [] : self[index..<count]
        self = left + newArray + right
    }
    
    func get(index: Int) -> T? {
        return 0 <= index && index < count ? self[index] : nil
    }
}