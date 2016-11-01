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
        self.location = range.lowerBound
        self.length = range.upperBound - range.lowerBound
    }
}
