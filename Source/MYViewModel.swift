//
//  MYViewModel.swift
//  Hakuba
//
//  Created by Le VanNghia on 2/14/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import Foundation

public protocol MYViewModelDelegate : class {
    func didCallSelectionHandler(view: MYBaseViewProtocol)
    func reloadView(index: Int, section: Int, animation: MYAnimation)
    func reloadHeader(section: Int)
    func reloadFooter(section: Int)
}

public class MYViewModel : NSObject, MYBaseViewDelegate {
    var action: MYSelectionHandler?
    weak var delegate: MYViewModelDelegate?
    var userData: AnyObject?
    
    public init(userData: AnyObject? = nil, selectionHandler: MYSelectionHandler?) {
        self.userData = userData
        self.action = selectionHandler
    }
    
    public func didSelect(view: MYBaseViewProtocol) {
        delegate?.didCallSelectionHandler(view)
        action?(view)
    }
}