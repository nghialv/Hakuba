//
//  UITableViewExt.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

extension UITableView {
    func registerCellByNib<T: UITableViewCell>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerCell<T: UITableViewCell>(t: T.Type) {
        register(t, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerHeaderFooterByNib<T: UITableViewHeaderFooterView>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        register(nib, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(t: T.Type) {
        register(t, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(t: T.Type, forIndexPath indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: t.reuseIdentifier, for: indexPath) as! T
    }
}
