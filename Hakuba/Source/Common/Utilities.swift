//
//  Utilities.swift
//  Example
//
//  Created by Keeeeen on 2018/08/09.
//

import Foundation

func classNameOf(_ aClass: AnyClass) -> String {
    return String(describing: aClass).components(separatedBy: ".").last!
}
