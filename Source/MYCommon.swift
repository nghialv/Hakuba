//
//  MYCommon.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public typealias MYSelectionHandler = (MYBaseViewProtocol) -> ()
public typealias MYAnimation = UITableViewRowAnimation

public protocol MYBaseViewProtocol {
    func emitSelectedEvent(_: MYBaseViewProtocol)
}

public protocol MYBaseViewDelegate : class {
    func didSelect(view: MYBaseViewProtocol)
}
