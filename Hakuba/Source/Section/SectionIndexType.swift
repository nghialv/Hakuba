//
//  SectionIndexType.swift
//  Example
//
//  Created by Keeeeen on 2018/08/09.
//

import Foundation

public protocol SectionIndexType: CaseIterable, RawRepresentable where Self.RawValue == Int {}
