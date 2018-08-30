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
    
    private lazy var hakuba: Hakuba = Hakuba(tableView: tableView)
    
    override func viewWillAppear(_ animated: Bool) {
        hakuba.deselectAllCells(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = .init()
        
        hakuba
            .registerCellByNib(CustomCell.self)
            .registerHeaderFooterByNib(CustomHeaderView.self)
        
        // Top section
        
        let topCellmodels = (0..<15).map { [weak self] i -> CellModel in
            let title = "Section 0 : index \(i)"
            
            return CustomCellModel(title: title) { _ in
                print("Did select new cell : \(i)")
                self?.pushChildViewController()
            }
        }
        
        // Center section
        
        let centerCellmodels = (0..<20).map { [weak self] i -> CellModel in
            let title = "Section 1 : index \(i)"
            
            return CustomCellModel(title: title) { _ in
                print("Did select new cell : \(i)")
                self?.pushChildViewController()
            }
        }
        
        let topSection = Section()
        topSection.header = CustomHeaderViewModel(text: "Top header")
        
        let centerSection = Section()
        centerSection.header = CustomHeaderViewModel(text: "Center header")
        
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
        let vc = storyboard.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
