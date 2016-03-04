//
//  Common.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import Foundation

func classNameOf(aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
}