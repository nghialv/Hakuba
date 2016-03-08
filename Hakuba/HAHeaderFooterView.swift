//
//  HAHeaderFooterView.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HAHeaderFooterView: UITableViewHeaderFooterView {
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
    
    public func configureView(viewModel: HAHeaderFooterViewModel) {
    }
   
    public func didChangeFloatingState(isFloating: Bool, section: Int) {
    }
    
    public func willDisplay(tableView: UITableView, section: Int) {
    }
    
    public func didEndDisplaying(tableView: UITableView, section: Int) {
    }
}

// MARK - Hightlight

public extension HAHeaderFooterView {
    func highlight(animated: Bool) {
    }
    
    func unhighlight(animated: Bool) {
    }
}

// MARK - Touch events

public extension HAHeaderFooterView {
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
            //emitSelectedEvent(self)
        }
    }
}
