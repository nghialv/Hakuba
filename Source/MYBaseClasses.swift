//
//  BaseClasses.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public typealias MYSelectionHandler = (MYBaseViewProtocol) -> ()
public typealias MYAnimation = UITableViewRowAnimation

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

public enum MYReloadType {
    case InsertRows(UITableViewRowAnimation)
    case DeleteRows(UITableViewRowAnimation)
    case ReloadRows(UITableViewRowAnimation)
    case ReloadSection(UITableViewRowAnimation)
    case ReloadTableView
    case None
}
