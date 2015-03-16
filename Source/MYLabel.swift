//
//  MYLabel.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYLabel : UILabel {
    override public var bounds: CGRect {
        didSet {
            self.preferredMaxLayoutWidth = self.bounds.width
        }
    }
}