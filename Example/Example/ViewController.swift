//
//  ViewController.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate lazy var hakuba: Hakuba = Hakuba(tableView: self.tableView)
    
    override func viewWillAppear(_ animated: Bool) {
        hakuba.deselectAllCells(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hakuba.registerCellByNib(CustomCell.self)
      
        let cm1 = CustomCellModel(title: "Test cell") { [weak self] _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CellTestViewController") as! CellTestViewController
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        let cm2 = CustomCellModel(title: "Test header footer") { [weak self] _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HeaderFooterTestViewController") as! HeaderFooterTestViewController
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let topSection = Section()
        
        hakuba
            .reset([topSection])
            .bump()
        
        topSection
            .reset([cm1, cm2])
            .bump()
    }
}

