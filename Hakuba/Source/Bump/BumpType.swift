//
//  Bump.swift
//  Example
//
//  Created by Keeeeen on 2018/08/09.
//

import Foundation

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
