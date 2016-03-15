//
//  HeaderFooterView.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

public class HeaderFooterView: UITableViewHeaderFooterView {
    weak var _viewmodel: HeaderFooterViewModel?
    
    public func configureView(viewmodel: HeaderFooterViewModel) {
        _viewmodel = viewmodel
        configure()
    }
    
    public func configure() {
    }
   
    public func didChangeFloatingState(isFloating: Bool, section: Int) {
    }
    
    public func willDisplay(tableView: UITableView, section: Int) {
    }
    
    public func didEndDisplaying(tableView: UITableView, section: Int) {
    }
}
