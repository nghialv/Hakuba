//
//  MYHeaderFooterView.swift
//  Hakuba
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
    public var selectionEnabled = true
    
    public init(viewClass: AnyClass, userData: AnyObject?, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = String.my_className(viewClass)
        super.init(userData: userData, selectionHandler: selectionHandler)
    }
    
    func slide() -> Self {
        if isHeader {
            delegate?.reloadHeader(section)
        } else {
            delegate?.reloadFooter(section)
        }
        return self
    }
}

public class MYHeaderFooterView : UITableViewHeaderFooterView, MYBaseViewProtocol {
    class var identifier: String { return String.my_className(self) }
    private weak var delegate: MYBaseViewDelegate?
    public var selectionEnabled = true
    
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
        selectionEnabled = data.selectionEnabled
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
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if selectionEnabled {
            highlight(false)
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        if selectionEnabled {
            unhighlight(false)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if selectionEnabled {
            emitSelectedEvent(self)
        }
    }
}