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
        registerNib(nib, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerCell<T: UITableViewCell>(t: T.Type) {
        registerClass(t, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerHeaderFooterByNib<T: UITableViewHeaderFooterView>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        registerNib(nib, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(t: T.Type) {
        registerClass(t, forHeaderFooterViewReuseIdentifier: t.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(t: T.Type, forIndexPath indexPath: NSIndexPath) -> T {
        return dequeueReusableCellWithIdentifier(t.reuseIdentifier, forIndexPath: indexPath) as! T
    }
}