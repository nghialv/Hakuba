//
//  HeaderFooterViewController.swift
//  Example
//
//  Created by Le VanNghia on 3/15/16.
//
//

import UIKit

class HeaderFooterTestViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var hakuba: Hakuba = Hakuba(tableView: self.tableView)
    
    override func viewWillAppear(animated: Bool) {
        hakuba.deselectAllCells(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hakuba.registerCellByNib(CustomCell)
        
        // Top section
        
        let topCellmodels = (0..<15).map { [weak self] i -> CellModel in
            let title = "Section 0 : index \(i)"
            
            return CustomCellModel(title: title) { _ in
                print("Did select new cell : \(i)")
                self?.pushChildViewController()
            }
        }
        
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

        let topSection = Section()
        let centerSection = Section()
        
        hakuba
            .reset([topSection, centerSection])
            .bump()
        
        topSection
            .reset(topCellmodels)
        
        centerSection
            .append(centerCellmodels)
        
        hakuba
            .bump()
    }
    
    func pushChildViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("ChildViewController") as! ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
