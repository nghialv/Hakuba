//
//  MYHeaderFooterView.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYHeaderFooterViewModel : MYViewModel {
    let identifier: String
    internal(set) var section: Int = 0
    internal(set) var isHeader = true
    public var viewHeight: CGFloat = 44
    public var isEnabled = true
    
    public init(viewClass: AnyClass, userData: AnyObject?, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = String.className(viewClass)
        super.init(userData: userData, selectionHandler: selectionHandler)
    }
    
    func fire() -> Self {
        if isHeader {
            delegate?.reloadHeader(section)
        } else {
            delegate?.reloadFooter(section)
        }
        return self
    }
}

public class MYHeaderFooterView : UITableViewHeaderFooterView, MYBaseViewProtocol {
    class var identifier: String { return String.className(self) }
    private weak var delegate: MYBaseViewDelegate?
    
    public override init() {
        super.init()
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public func setup() {
    }
    
    public func configureView(data: MYHeaderFooterViewModel) {
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
    func highlight(animated: Bool) {
    }
    
    func unhighlight(animated: Bool) {
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