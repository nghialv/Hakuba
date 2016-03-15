//
//  CustomHeaderViewModel.swift
//  Example
//
//  Created by Le VanNghia on 3/15/16.
//
//

import Foundation

final class CustomHeaderViewModel: HeaderFooterViewModel {
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(view: CustomHeaderView.self)
    }
}