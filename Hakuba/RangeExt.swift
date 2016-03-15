//
//  RangeExt.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

extension NSRange {
    init(range: Range<Int>) {
        self.location = range.startIndex
        self.length = range.endIndex - range.startIndex
    }
}