//
//  MYTableViewCell.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYTableViewCellData : MYBaseViewData {
    let identifier: String
    var cellHeight: CGFloat = 44
    var cellSelectionEnabled = true
    var calculatedHeight: CGFloat?
    var dynamicHeightEnabled: Bool = false {
        didSet {
            calculatedHeight = nil
        }
    }
    
    init(cellClass: AnyClass, height: CGFloat = 44, userData: AnyObject?, actionHander: MYActionHandler?) {
        self.identifier = String.className(cellClass)
        self.cellHeight = height
        super.init(userData: userData, actionHandler: actionHander)
    }
}

public class MYTableViewCell : UITableViewCell, MYBaseViewProtocol {
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public func setup() {
    }
    
    public func configureCell(data: MYTableViewCellData) {
        self.delegate = data
        unhighlight(false)
    }
}

// MARK - Hightlight
public extension MYTableViewCell {
    // ignore the default handling
    override func setHighlighted(highlighted: Bool, animated: Bool) {
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    func highlight(animated: Bool) {
        super.setHighlighted(true, animated: animated)
    }
    
    func unhighlight(animated: Bool) {
        super.setHighlighted(false, animated: animated)
    }
}

// MARK - Touch events
public extension MYTableViewCell {
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
        delegate?.didSelect(self)
    }
}