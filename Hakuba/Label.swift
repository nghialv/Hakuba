//
//  Label.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

open class Label : UILabel {
    override open var bounds: CGRect {
        didSet {
            self.preferredMaxLayoutWidth = self.bounds.width
        }
    }
}
