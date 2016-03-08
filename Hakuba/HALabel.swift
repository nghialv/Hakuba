//
//  HALabel.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HALabel : UILabel {
    override public var bounds: CGRect {
        didSet {
            self.preferredMaxLayoutWidth = self.bounds.width
        }
    }
}
