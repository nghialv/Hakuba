//
//  BaseClasses.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

typealias MYSelectionHandler = () -> ()

public protocol MYBaseViewProtocol {
    func highlight(Bool)
    func unhighlight(Bool)
    func emitSelectedEvent(MYBaseViewProtocol)
}

public protocol MYBaseViewDataDelegate : class {
    func didSelectView(view: MYBaseViewProtocol)
}

public protocol MYBaseViewDelegate : class {
    func didSelect(view: MYBaseViewProtocol)
}

public class MYBaseViewData : NSObject, MYBaseViewDelegate {
    var action: MYSelectionHandler?
    weak var delegate: MYBaseViewDataDelegate?
    var userData: AnyObject?
    
    init(userData: AnyObject? = nil, selectionHandler: MYSelectionHandler?) {
        self.userData = userData
        self.action = selectionHandler
    }
    
    public func didSelect(view: MYBaseViewProtocol) {
        action?()
        delegate?.didSelectView(view)
    }
}