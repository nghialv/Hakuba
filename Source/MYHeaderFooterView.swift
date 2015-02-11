//
//  MYHeaderFooterView.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYHeaderFooterViewData : MYBaseViewData {
    let identifier: String
    var viewHeight: CGFloat = 44
    var isEnabled = true
    
    init(viewClass: AnyClass, userData: AnyObject?, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = String.className(viewClass)
        super.init(userData: userData, selectionHandler: selectionHandler)
    }
}

public class MYHeaderFooterView : UITableViewHeaderFooterView, MYBaseViewProtocol {
    class var identifier: String { return String.className(self) }
    private weak var delegate: MYBaseViewDelegate?
    
    override init() {
        super.init()
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
    }
    
    func configureView(data: MYHeaderFooterViewData) {
        self.delegate = data
    }
    
    public func emitSelectedEvent(view: MYBaseViewProtocol) {
        delegate?.didSelect(view)
    }
    
    public func didChangeFloatingState(isFloating: Bool) {
        
    }
}

// MARK - Hightlight
public extension MYHeaderFooterView {
    public func highlight(animated: Bool) {
    }
    
    public func unhighlight(animated: Bool) {
    }
}

// MARK - Touch events
public extension MYHeaderFooterView {
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        highlight(false)
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        unhighlight(false)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        emitSelectedEvent(self)
    }
}