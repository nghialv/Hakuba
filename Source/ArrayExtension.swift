//
//  ArrayExtension.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

extension Array {
    mutating func insert(newArray: Array, atIndex index: Int) {
        let left = self[0..<Swift.max(0, index)]
        let right = index > count ? [] : self[index..<count]
        self = left + newArray + right
    }
}