//
//  MYViewModel.swift
//  MYTableViewManager
//
//  Created by Le VanNghia on 2/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

public protocol MYBaseViewDataDelegate : class {
    func didCallSelectionHandler(view: MYBaseViewProtocol)
    func reloadView(index: Int, section: Int, animation: MYAnimation)
}

public class MYViewModel : NSObject, MYBaseViewDelegate {
    var action: MYSelectionHandler?
    weak var delegate: MYBaseViewDataDelegate?
    var userData: AnyObject?
    
    public init(userData: AnyObject? = nil, selectionHandler: MYSelectionHandler?) {
        self.userData = userData
        self.action = selectionHandler
    }
    
    public func didSelect(view: MYBaseViewProtocol) {
        action?(view)
        delegate?.didCallSelectionHandler(view)
    }
}