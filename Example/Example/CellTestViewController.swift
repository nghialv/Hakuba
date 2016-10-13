//
//  CellViewController.swift
//  Example
//
//  Created by Le VanNghia on 3/15/16.
//
//

import UIKit

enum SectionIndex: Int, SectionIndexType {
    case top
    case center
    
    static let count = 2
}

class CellTestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate lazy var hakuba: Hakuba = Hakuba(tableView: self.tableView)
    
    override func viewWillAppear(_ animated: Bool) {
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
            .reset(SectionIndex)
            .bump()
        
        let topSection = hakuba[SectionIndex.top]
        let centerSection = hakuba[SectionIndex.center]
        
        topSection
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
            centerSection
                .append(centerCellmodels)
                .bump(.left)
        }
        
        delay(3) {
            centerSection
                .remove(2...4)
                .bump(.right)
        }
        
        delay(5) {
            self.hakuba
                .move(0, to: 1)
                .bump()
        }
        
        delay(7.5) {
            topSection
                .remove(1)
                .bump(.middle)
        }
        
        delay(10) {
            topSection
                .remove(0)
                .bump(.right)
        }
        
        delay(12.5) {
            topSection
                .remove(0)
                .bump(.right)
        }
        
        delay(15) {
            self.hakuba
                .reset()
                .bump()
        }
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

