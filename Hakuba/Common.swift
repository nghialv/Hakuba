//
//  Common.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

public typealias HASelectionHandler = (HACell) -> ()

public typealias HAAnimation = UITableViewRowAnimation

public protocol SectionIndex {
    var intValue: Int { get }
}

public enum HakubaBumpType {
    case Reload
    case Insert(NSIndexSet)
    case Move(Int, Int)
    case Delete(NSIndexSet)
}

public enum SectionBumpType {
    case Reload(NSIndexSet)
    case Insert([NSIndexPath])
    case Move(NSIndexPath, NSIndexPath)
    case Delete([NSIndexPath])
}

public enum ItemBumpType {
    case Reload(NSIndexPath)
    case ReloadHeader(Int)
    case ReloadFooter(Int)
}

func classNameOf(aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
}
