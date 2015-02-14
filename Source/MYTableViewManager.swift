//
//  MYTableViewManager.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//


import UIKit

@objc public protocol MYTableViewManagerDelegate : class {
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    optional func scrollViewWillBeginDecelerating(scrollView: UIScrollView)
    optional func scrollViewWillBeginDragging(scrollView: UIScrollView)
}

public class MYTableViewManager : NSObject {
    public weak var delegate: MYTableViewManagerDelegate?
    
    private weak var tableView: UITableView?
    private var sections: [Int: MYSection] = [:]
    private var numberOfSections: Int = 0
    
    private var selectedCells = [MYBaseViewProtocol]()
    private var heightCalculationCells: [String: MYTableViewCell] = [:]
    private var currentTopSection = 0
    private var willFloatingSection = -1
    public var loadmoreHandler: (() -> ())?
    public var loadmoreEnabled = false
    public var loadmoreThreshold: CGFloat = 25
    
    public init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func deselectAllCells() {
        for view in selectedCells {
            view.unhighlight(true)
        }
        selectedCells.removeAll(keepCapacity: false)
    }
    
    public func resetAllData() {
        sections = [:]
        numberOfSections = 0
        selectedCells = []
        heightCalculationCells = [:]
        currentTopSection = 0
        willFloatingSection = -1
    }
    
    public subscript(index: Int) -> MYSection {
        get {
            if let s = sections[index] {
                return s
            }
            // TODO : update number of sections
            numberOfSections = index + 1
            let ns = MYSection()
            sections[index] = ns
            return ns
        }
    }
}

public extension MYTableViewManager {
    func insertSection(section: MYSection, atIndex index: Int) {
        
    }
    
    func removeSectionAtIndex(index: Int) {
        
    }
    
    func removeAllSections() {
        
    }
}

// MARK - tableView methods
public extension MYTableViewManager {
    func reloadTableView() {
        tableView?.reloadData()
    }
    
    func reloadSection(section: Int, animation: UITableViewRowAnimation) {
        tableView?.reloadSections(NSIndexSet(index: section), withRowAnimation: animation)
    }
    
    func cellForRowAtSection(section: Int, row: Int) -> MYTableViewCell? {
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        return tableView?.cellForRowAtIndexPath(indexPath) as? MYTableViewCell
    }
}

// MARK - header/footer 
public extension MYTableViewManager {
    func setHeaderData(data: MYHeaderFooterViewModel, inSection section: Int) {
        self.sections[section]?.header = data
    }
    
    func setFooterData(data: MYHeaderFooterViewModel, inSection section: Int) {
        self.sections[section]?.footer = data
    }
}

// MARK - private methods
private extension MYTableViewManager {
    func addSelectedView(view: MYBaseViewProtocol) {
        deselectAllCells()
        selectedCells = [view]
    }
    
    func setBaseViewDataDelegate(dataList: [MYViewModel]) {
        for data in dataList {
            data.delegate = self
        }
    }
    
    func calculateHeightForConfiguredSizingCell(cell: MYTableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, tableView?.bounds.width ?? UIScreen.mainScreen().bounds.width, cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1.0
    }
}

// MARK - MYBaseViewDataDelegate
extension MYTableViewManager : MYBaseViewDataDelegate {
    public func didSelectView(view: MYBaseViewProtocol) {
        addSelectedView(view)
    }
}

// MARK - UITableViewDelegate
extension MYTableViewManager : UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            if !cellData.dynamicHeightEnabled {
                return cellData.cellHeight
            }
            if let h = cellData.calculatedHeight {
                return h
            }
            if heightCalculationCells[cellData.identifier] == nil {
                heightCalculationCells[cellData.identifier] = tableView.dequeueReusableCellWithIdentifier(cellData.identifier) as? MYTableViewCell
            }
            if let cell = heightCalculationCells[cellData.identifier] {
                cell.configureCell(cellData)
                cellData.calculatedHeight = calculateHeightForConfiguredSizingCell(cell)
                return cellData.calculatedHeight!
            }
        }
        return 0
    }
   
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            return cellData.cellHeight
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let header = self.sections[section]?.header {
            return header.isEnabled ? header.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = self.sections[section]?.header {
            if !header.isEnabled {
                return nil
            }
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(header.identifier) as MYHeaderFooterView
            headerView.configureView(header)
            return headerView
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let footer = self.sections[section]?.footer {
            return footer.isEnabled ? footer.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = self.sections[section]?.footer {
            if !footer.isEnabled {
                return nil
            }
            let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footer.identifier) as MYHeaderFooterView
            footerView.configureView(footer)
            return footerView
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            if let myCell = cell as? MYTableViewCell {
                myCell.willAppear(cellData)
            }
        }
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            if let myCell = cell as? MYTableViewCell {
                myCell.didDisappear(cellData)
            }
        }
    }
}

// MARK - MYTableViewManager
extension MYTableViewManager : UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section]?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellData.identifier, forIndexPath: indexPath) as MYTableViewCell
            cell.configureCell(cellData)
            return cell
        }
        return UITableViewCell()
    }
}

// MARK - register cell and header/footer
public extension MYTableViewManager {
    func registerCellClass(cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        tableView?.registerClass(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewClass(viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        tableView?.registerClass(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewNib(viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView?.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

// MARK - loadmore
extension MYTableViewManager {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
        
        if let indexPath = tableView?.indexPathsForVisibleRows()?.first as? NSIndexPath {
            if currentTopSection != indexPath.section {
                if let headerView = tableView?.headerViewForSection(currentTopSection) as? MYHeaderFooterView {
                    headerView.didChangeFloatingState(false)
                }
                if let headerView = tableView?.headerViewForSection(indexPath.section) as? MYHeaderFooterView {
                    headerView.didChangeFloatingState(true)
                }
                if currentTopSection > indexPath.section {
                    willFloatingSection = indexPath.section
                }
                currentTopSection = indexPath.section
            }
        }
        
        if !loadmoreEnabled {
            return
        }
        
        let offset = scrollView.contentOffset
        let y = offset.y + scrollView.bounds.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        if y > h - loadmoreThreshold {
            loadmoreEnabled = false
            self.loadmoreHandler?()
        }
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == willFloatingSection {
            if let view = view as? MYHeaderFooterView {
                view.didChangeFloatingState(true)
                willFloatingSection = -1
            }
        }
    }
}

// MARK - UIScrollViewDelegate
extension MYTableViewManager {
    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
}

// MARK - private methods
private extension MYTableViewManager {
    func cellViewModelAtIndexPath(indexPath: NSIndexPath) -> MYCellViewModel? {
        return self.sections[indexPath.section]?[indexPath.row]
    }
}