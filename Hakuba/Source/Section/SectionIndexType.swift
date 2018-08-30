//
//  SectionIndexType.swift
//  Example
//
//  Created by Keeeeen on 2018/08/09.
//

import Foundation

public protocol SectionIndexType: RawRepresentable where Self.RawValue == Int {
    static var count: Int { get }
}
