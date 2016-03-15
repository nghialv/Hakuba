//
//  ViewController.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

enum ExSection : Int, SectionIndex {
    case Top = 0
    case Center
    
    var intValue: Int {
        return self.rawValue
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var hakuba: Hakuba = Hakuba(tableView: self.tableView)
    
    override func viewWillAppear(animated: Bool) {
        hakuba.deselectAllCells(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hakuba.registerCellByNib(CustomCell)
      
        // Top section
        
        let topCellmodels = (0..<2).map { [weak self] i -> CellModel in
            let title = "Section 0 : index \(i)"
            
            return CustomCellModel(title: title) { _ in
                print("Did select new cell : \(i)")
                self?.pushChildViewController()
            }
        }
        
        hakuba
            .reset([Section(), Section()])
            .bump()
        
        hakuba[ExSection.Top]
            .reset(topCellmodels)
            .bump()
        
        // Center section
        
        let longTitle1 = "Don't have to write the code for UITableViewDelegate and UITableViewDataSource protocols"
        let longTitle2 = "Support dynamic cell height from ios7"
        let titles = ["title 1", "title 2", "title 3", "title 4", "title 5", longTitle1, longTitle2]
        
        let centerCellmodels = titles.map { [weak self] title -> CellModel in
            let data = CustomCellModel(title: "Section 1: " + title) { _ in
                print("Did select cell with title = \(title)")
                self?.pushChildViewController()
            }
            data.dynamicHeightEnabled = true
            return data
        }
        
        delay(1.5) {
            self.hakuba[ExSection.Center]
                .append(centerCellmodels)
                .bump(.Left)
        }
        
        delay(3) {
            self.hakuba[ExSection.Center]
                .remove(2...4)
                .bump(.Right)
        }
        
        delay(5) {
            self.hakuba
                .move(0, to: 1)
                .bump()
        }
        
        delay(7.5) {
            self.hakuba[ExSection.Center]
                .remove(1)
                .bump(.Middle)
        }
        
        delay(10) {
            self.hakuba[ExSection.Center]
                .remove(0)
                .bump(.Right)
        }
        
        delay(12.5) {
            self.hakuba[ExSection.Center]
                .remove(0)
                .bump(.Right)
        }
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChildViewController") as! ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

