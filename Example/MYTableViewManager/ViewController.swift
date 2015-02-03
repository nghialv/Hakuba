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
        tableViewManager.delegate = self
        
        tableViewManager.registerCellNib(CustomCell)
       
        let longTitle1 = "Don't have to write the code for UITableViewDelegate and UITableViewDataSource protocols"
        let longTitle2 = "Support dynamic cell height from ios7"
        
        let titles = ["title 1", "title 2", "title 3", "title 4", "title 5", longTitle1, longTitle2]
        
        let cellData = titles.map { [weak self] title -> MYTableViewCellData in
            let data = MYTableViewCellData(cellClass: CustomCell.self, userData: title) { _ in
                println("Did select cell with title = \(title)")
                self?.pushChildViewController()
            }
            data.dynamicHeightEnabled = true
            return data
        }
        tableViewManager.resetWithData(cellData, inSection: 0)
       
        tableViewManager.loadmoreHandler = { [weak self] in
            println("Loadmore")
            self?.delay(1) {
                self?.tableViewManager.loadmoreEnabled = true
                return
            }
        }
        
        delay(1.0) {
            let titles = ["new cell 1", "new cell 2"]
            let newCellData = titles.map { [weak self] title -> MYTableViewCellData in
                return MYTableViewCellData(cellClass: CustomCell.self, userData: title) { _ in
                    println("Did select new cell : \(title)")
                    self?.pushChildViewController()
                }
            }
            self.tableViewManager.resetWithData(newCellData, inSection: 5)
            //self.tableViewManager.insertData(newCellData, inSection: 0, atRow: 1, reloadType: .InsertRows(.Middle))
        }
        
        delay(2.0) {
            self.tableViewManager.removeDataInSection(0, atRow: 2)
        }
        
        delay(3.0) {
            self.tableViewManager.updateUserData("Last cell", inSection: 5, atRow: 1)
        }
        
        delay(5.0) {
            let titles = ["inserted cell 1", "inserted cell 2", "inserted cell 3"]
            let newCellData = titles.map { [weak self] title -> MYTableViewCellData in
                return MYTableViewCellData(cellClass: CustomCell.self, height: 100, userData: title) { _ in
                    println("Did select new cell : \(title)")
                    self?.pushChildViewController()
                }
            }
            self.tableViewManager.insertDataBeforeLastRow(newCellData, inSection: 0, reloadType: .InsertRows(.Middle))
        }
        
        delay(6.0) {
            self.tableViewManager.removeLastDataInSection(0)
            //self.tableViewManager.removeDataInSection(0, inRange: (7..<9), reloadType: .DeleteRows(.Middle))
        }
        
        tableViewManager.loadmoreEnabled = true
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChildViewController") as ChildViewController
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

extension ViewController : MYTableViewManagerDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        println("OK")
    }
}

