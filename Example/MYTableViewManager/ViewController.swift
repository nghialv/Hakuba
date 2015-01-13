//
//  ViewController.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var tableViewManager: MYTableViewManager!
    
    override func viewWillAppear(animated: Bool) {
        tableViewManager?.deselectAllCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewManager = MYTableViewManager(tableView: tableView)
        tableViewManager.registerCellNib(CustomCell)
        
        let titles = ["title 1", "title 2", "title 3", "title 4", "title 5"]
        
        let cellData = titles.map { [weak self] title -> MYTableViewCellData in
            return MYTableViewCellData(cellClass: CustomCell.self, userData: title) {
                println("Did select cell with title = \(title)")
                self?.pushChildViewController()
            }
        }
        tableViewManager.resetDataInSection(0, data: cellData, reloadSection: true)
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChildViewController") as ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

