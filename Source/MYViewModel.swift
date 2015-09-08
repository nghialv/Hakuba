//
//  MYViewModel.swift
//  Hakuba
//
//  Created by Le VanNghia on 2/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation
import UIKit

public protocol MYViewModelDelegate : class {
    func didCallSelectionHandler(view: MYBaseViewProtocol)
    func reloadView(index: Int, section: Int, animation: MYAnimation)
    func reloadHeader(section: Int)
    func reloadFooter(section: Int)
}

public class MYViewModel : NSObject, MYBaseViewDelegate {
    public var selectable = true
    public var height: CGFloat = 44
    public var selectionHandler: MYSelectionHandler?
    weak var delegate: MYViewModelDelegate?
    
    public init(selectionHandler: MYSelectionHandler?) {
        self.selectionHandler = selectionHandler
    }
    
    public func didSelect(view: MYBaseViewProtocol) {
        if selectable {
            delegate?.didCallSelectionHandler(view)
            selectionHandler?(view)
        }
    }
}