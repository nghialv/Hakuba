//
//  CustomHeaderView.swift
//  Example
//
//  Created by Le VanNghia on 3/15/16.
//
//

import UIKit

final class CustomHeaderView: HeaderFooterView, HeaderFooterViewType {
    typealias ViewModel = CustomHeaderViewModel
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var floatingLabel: UILabel!
    
    override func configure() {
        guard let vm = viewmodel else {
            return
        }
        
        label.text = vm.text
    }
    
    override func didChangeFloatingState(_ isFloating: Bool, section: Int) {
        super.didChangeFloatingState(isFloating, section: section)
        
        let title = isFloating ? "F \(section)" : "n \(section)"
        floatingLabel.text = title
    }
}
