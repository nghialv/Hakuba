//
//  UITableViewCellExt.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

extension UITableViewCell {
    static var nibName: String {
        return classNameOf(self)
    }
    
    static var reuseIdentifier: String {
        return classNameOf(self)
    }
}