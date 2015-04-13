//
//  ViewController.swift
//  Hakuba
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

enum Section : Int, SectionIndex {
    case Top = 0
    case Center
    
    var intValue: Int {
        return self.rawValue
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var hakuba: Hakuba!
    
    override func viewWillAppear(animated: Bool) {
        hakuba?.deselectAllCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hakuba = Hakuba(tableView: tableView)
        hakuba.registerCellNib(CustomCell)
      
        // top section
        let cellmodels0 = (0..<2).map { [weak self] i -> MYCellModel in
            let title = "Section 0 : index \(i)"
            return CustomCellModel(title: title) { _ in
                println("Did select new cell : \(i)")
                self?.pushChildViewController()
            }
        }
        hakuba[Section.Top].reset(cellmodels0)
        
        // center section
        let longTitle1 = "Don't have to write the code for UITableViewDelegate and UITableViewDataSource protocols"
        let longTitle2 = "Support dynamic cell height from ios7"
        let titles = ["title 1", "title 2", "title 3", "title 4", "title 5", longTitle1, longTitle2]
        
        let cellmodels1 = titles.map { [weak self] title -> MYCellModel in
            let data = CustomCellModel(title: "Section 1: " + title) { _ in
                println("Did select cell with title = \(title)")
                self?.pushChildViewController()
            }
            data.dynamicHeightEnabled = true
            return data
        }
        delay(1.5) {
            self.hakuba[Section.Center].append(cellmodels1)
                                       .slide()
            
            return
        }
        
        delay(3) {
            self.hakuba[Section.Center].remove(2...4)
                                       .slide(.Left)
            
            return
        }
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChildViewController") as! ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

