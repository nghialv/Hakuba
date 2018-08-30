//
//  UITableViewExt.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

extension UITableView {
    func registerCellByNib<T: UITableViewCell>(cellType: T.Type) {
        let nib = UINib(nibName: cellType.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerCell<T: UITableViewCell>(cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func registerHeaderFooterByNib<T: UITableViewHeaderFooterView>(viewType: T.Type) {
        let nib = UINib(nibName: viewType.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(viewType: T.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: viewType.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as! T
    }
}
