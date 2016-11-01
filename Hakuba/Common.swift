//
//  Common.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

public typealias SelectionHandler = (Cell) -> ()

public typealias Animation = UITableViewRowAnimation

public protocol SectionIndexType {
    var intValue: Int { get }
    static var count: Int { get }
}

public extension SectionIndexType where Self: RawRepresentable, Self.RawValue == Int {
    var intValue: Int {
        return rawValue
    }
}

public enum HakubaBumpType {
    case reload
    case insert(IndexSet)
    case move(Int, Int)
    case delete(IndexSet)
}

public enum SectionBumpType {
    case reload(IndexSet)
    case insert([IndexPath])
    case move(IndexPath, IndexPath)
    case delete([IndexPath])
}

public enum ItemBumpType {
    case reload(IndexPath)
    case reloadHeader(Int)
    case reloadFooter(Int)
}

func classNameOf(_ aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).components(separatedBy: ".").last!
}
