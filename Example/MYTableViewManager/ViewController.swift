//
//  ViewController.swift
//  MYTableViewManager
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
    private var tvm: MYTableViewManager!
    
    override func viewWillAppear(animated: Bool) {
        tvm?.deselectAllCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvm = MYTableViewManager(tableView: tableView)
        tvm.delegate = self
        
        tvm.registerCellNib(CustomCell)
        delay(1) {
            _ = self.start()
        }
    }
   
    func start() {
        
        for index in 0...4 {
            let cvm = (0..<2).map { [weak self] i -> MYCellModel in
                return MYCellModel(cellClass: CustomCell.self, userData: "index \(index*2 + i)") { _ in
                    println("Did select new cell : \(index + i)")
                    self?.pushChildViewController()
                }
            }
            tvm[Section.Top].insert(cvm[0], atIndex: 0)
                  //.fire(.Left)
            tvm[Section.Top].append(cvm[1])
            
            //tvm[0][index*2]?.userData = "new title: \(index)"
            //tvm[0][index + 1]?.fire()
        }
        //tvm[0].remove(0)
        self.tvm[Section.Top].fire()
       
        delay(2) {
            for index in 0...4 {
                self.tvm[Section.Top].remove(index+1)
                    //.fire(.Right)
            }
        }
        
        println("finish setting")
        delay(4) {
            self.tvm[Section.Top].fire()
            return
        }
        
        delay(7) {
            //self.tvm[0].fire()
            
            for i in 0...200 {
                let secIndex = Int(arc4random() % 200)
                let section = self.tvm[secIndex]
                NSLog("\(section.count)")
            }
            return
        }
        /*
        let longTitle1 = "Don't have to write the code for UITableViewDelegate and UITableViewDataSource protocols"
        let longTitle2 = "Support dynamic cell height from ios7"
        
        let titles = ["title 1", "title 2", "title 3", "title 4", "title 5", longTitle1, longTitle2]
        
        let cellData = titles.map { [weak self] title -> MYCellModel in
            let data = MYCellModel(cellClass: CustomCell.self, userData: title) { _ in
                println("Did select cell with title = \(title)")
                self?.pushChildViewController()
            }
            data.dynamicHeightEnabled = true
            return data
        }
        
        self.tvm[0].reset(cellData)
            .fire()
        
        delay(2) {
            let titles = ["new cell 1", "new cell 2"]
            let newCellData = titles.map { [weak self] title -> MYCellModel in
                return MYCellModel(cellClass: CustomCell.self, userData: title) { _ in
                    println("Did select new cell : \(title)")
                    self?.pushChildViewController()
                }
            }
            self.tvm[0].insert(newCellData, atIndex: 2)
                .fire(.Middle)
        }
       
        delay(5) {
            self.tvm[0].remove(1)
                .fire(.Left)
            return
        }
        */
        /*
        tvm.loadmoreHandler = { [weak self] in
            println("Loadmore")
            self?.delay(1) {
                self?.tvm.loadmoreEnabled = true
                return
            }
        }
    
        
        
        delay(3.0) {
            self.tvm.updateUserData("Last cell", inSection: 5, atRow: 1)
        }
        
        delay(5.0) {
            let titles = ["inserted cell 1", "inserted cell 2", "inserted cell 3"]
            let newCellData = titles.map { [weak self] title -> MYCellModel in
                return MYCellModel(cellClass: CustomCell.self, height: 100, userData: title) { _ in
                    println("Did select new cell : \(title)")
                    self?.pushChildViewController()
                }
            }
            self.tvm.insertDataBeforeLastRow(newCellData, inSection: 0, reloadType: .InsertRows(.Middle))
        }
        
        delay(6.0) {
            self.tvm.removeLastDataInSection(0)
            //self.tvm.removeDataInSection(0, inRange: (7..<9), reloadType: .DeleteRows(.Middle))
        }
        
        tvm.loadmoreEnabled = true
        */
    }
    
    func appendItems(index: Int, num: Int) {
        let cvm = (0..<num).map { [weak self] i -> MYCellModel in
            return MYCellModel(cellClass: CustomCell.self, userData: "index \(index + i)") { _ in
                println("Did select new cell : \(index + i)")
                self?.pushChildViewController()
            }
        }
        self.tvm[0].append(cvm)
            .fire(.Left)
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
    }
}

