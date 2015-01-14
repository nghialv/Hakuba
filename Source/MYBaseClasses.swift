//
//  BaseClasses.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

typealias MYActionHandler = () -> ()

public protocol MYBaseViewProtocol {
    func highlight(Bool)
    func unhighlight(Bool)
}

public protocol MYBaseViewDataDelegate : class {
    func didSelectView(view: MYBaseViewProtocol)
}

public protocol MYBaseViewDelegate : class {
    func didSelect(view: MYBaseViewProtocol)
}

public class MYBaseViewData : NSObject, MYBaseViewDelegate {
    var action: MYActionHandler?
    weak var delegate: MYBaseViewDataDelegate?
    var userData: AnyObject?
    
    init(userData: AnyObject? = nil, actionHander: MYActionHandler?) {
        self.userData = userData
        self.action = actionHander
    }
    
    public func didSelect(view: MYBaseViewProtocol) {
        action?()
        delegate?.didSelectView(view)
    }
}