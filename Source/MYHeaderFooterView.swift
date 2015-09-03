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
    
    public var isEnabled = true
    
    public init<T: MYHeaderFooterView>(view: T.Type, userData: AnyObject?, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = view.reuseIdentifier
        super.init(selectionHandler: selectionHandler)
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
    private weak var delegate: MYBaseViewDelegate?
    public var selectable = true
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
	
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public func setup() {
    }
    
    public func configureView(viewModel: MYHeaderFooterViewModel) {
        self.delegate = viewModel
        selectable = viewModel.selectable
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
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if selectable {
            highlight(false)
        }
    }
	
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        if selectable {
            unhighlight(false)
        }
    }
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if selectable {
            emitSelectedEvent(self)
        }
    }
}