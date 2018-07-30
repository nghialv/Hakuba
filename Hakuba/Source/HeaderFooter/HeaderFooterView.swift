//
//  HeaderFooterView.swift
//  Example
//
//  Created by Le VanNghia on 3/5/16.
//
//

import UIKit

open class HeaderFooterView: UITableViewHeaderFooterView {
    weak var _viewmodel: HeaderFooterViewModel?
    
    open func configureView(_ viewmodel: HeaderFooterViewModel) {
        _viewmodel = viewmodel
        configure()
    }
    
    open func configure() {}
    open func didChangeFloatingState(_ isFloating: Bool, section: Int) {}
    open func willDisplay(_ tableView: UITableView, section: Int) {}
    open func didEndDisplaying(_ tableView: UITableView, section: Int) {}
}
