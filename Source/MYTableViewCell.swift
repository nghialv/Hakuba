//
//  MYTableViewCell.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

public class MYCellModel : MYViewModel {
    let identifier: String
    internal(set) var row: Int = 0
    internal(set) var section: Int = 0
    public var cellHeight: CGFloat = 44
    public var cellSelectionEnabled = true
    public var editable = false
    public var calculatedHeight: CGFloat?
    public var dynamicHeightEnabled: Bool = false {
        didSet {
            calculatedHeight = nil
        }
    }
    
    public init(cellClass: AnyClass, height: CGFloat = 44, userData: AnyObject?, selectionHandler: MYSelectionHandler? = nil) {
        self.identifier = String.my_className(cellClass)
        self.cellHeight = height
        super.init(userData: userData, selectionHandler: selectionHandler)
    }
    
    public func slide(_ animation: MYAnimation = .None) -> Self {
        delegate?.reloadView(row, section: section, animation: animation)
        return self
    }
}

public class MYTableViewCell : UITableViewCell, MYBaseViewProtocol {
    class var identifier: String { return String.my_className(self) }
    var cellSelectionEnabled = true
    private weak var delegate: MYBaseViewDelegate?
    weak var cellModel: MYCellModel?
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public func setup() {
    }
    
    public func configureCell(data: MYCellModel) {
        cellModel = data
        delegate = data
        cellSelectionEnabled = data.cellSelectionEnabled
        unhighlight(false)
    }
   
    public func emitSelectedEvent(view: MYBaseViewProtocol) {
        delegate?.didSelect(view)
    }
    
    public func willAppear(data: MYCellModel) {
        
    }
    
    public func didDisappear(data: MYCellModel) {
        
    }
}

// MARK - Hightlight
public extension MYTableViewCell {
    // ignore the default handling
    override func setHighlighted(highlighted: Bool, animated: Bool) {
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    public func highlight(animated: Bool) {
        super.setHighlighted(true, animated: animated)
    }
    
    public func unhighlight(animated: Bool) {
        super.setHighlighted(false, animated: animated)
    }
}

// MARK - Touch events
public extension MYTableViewCell {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
       super.touchesBegan(touches, withEvent: event)
        if cellSelectionEnabled {
            highlight(false)
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        if cellSelectionEnabled {
            unhighlight(false)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if cellSelectionEnabled {
            emitSelectedEvent(self)
        }
    }
}