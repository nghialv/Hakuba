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
    public var loadmoreHandler: (() -> ())?
    public var loadmoreEnabled = false
    public var loadmoreThreshold: CGFloat = 25
    public var sectionCount: Int {
        return sections.count
    }
    
    private weak var tableView: UITableView?
    private var sections: [MYSection] = []
   
    private let reloadTracker = MYReloadTracker()
    private var selectedCells = [MYBaseViewProtocol]()
    private var heightCalculationCells: [String: MYTableViewCell] = [:]
    private var currentTopSection = 0
    private var willFloatingSection = -1
    private var insertedSectionsRange: (Int, Int) = (100, -1)
    
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
    
    public func resetAll() -> Self {
        sections = []
        selectedCells = []
        heightCalculationCells = [:]
        currentTopSection = 0
        willFloatingSection = -1
        return self
    }
    
    public subscript(index: Int) -> MYSection {
        get {
            if let s = sections.my_get(index) {
                return s
            }
            let length = index + 1 - sectionCount
            
            let newSections = (sectionCount...index).map { i -> MYSection in
                let ns = MYSection()
                ns.delegate = self
                ns.index = i
                return ns
            }
           
            //let insertSet: NSIndexSet = NSIndexSet(indexesInRange: NSMakeRange(sectionCount, length))
            //tableView?.insertSections(insertSet, withRowAnimation: .None)
            let begin = min(insertedSectionsRange.0, sectionCount)
            let end = max(insertedSectionsRange.1, index + 1)
            insertedSectionsRange = (begin, end)

            sections += newSections
            return sections[index]
        }
    }
    
    private func syncSections(animation: MYAnimation) -> Bool {
        let length = insertedSectionsRange.1 - insertedSectionsRange.0
        if length > 0 {
            let insertSet: NSIndexSet =  NSIndexSet(indexesInRange: NSMakeRange(insertedSectionsRange.0, length))
            insertedSectionsRange = (100, -1)
            tableView?.insertSections(insertSet, withRowAnimation: animation)
            return true
        }
        return false
    }
}

public extension MYTableViewManager {
    func insertSection(section: MYSection, atIndex index: Int) -> Self {
        // TODO : implementation
        return self
    }
    
    func removeSectionAtIndex(index: Int) -> Self {
        // TODO : implementation
        return self
    }
    
    func fire(_ animation: MYAnimation = .None) -> Self {
        // TODO : implementation
        tableView?.reloadData()
        insertedSectionsRange = (100, -1)
        return self
    }
}

// MARK - MYSectionDelegate
extension MYTableViewManager : MYSectionDelegate {
    func reloadSections(index: Int, animation: MYAnimation) {
        if !syncSections(animation) {
            let indexSet = NSIndexSet(index: index)
            tableView?.reloadSections(indexSet, withRowAnimation: animation)
        }
    }
    
    func insertRows(indexPaths: [NSIndexPath], animation: MYAnimation) {
        if !syncSections(animation) {
            tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        }
    }
    
    func deleteRows(indexPaths: [NSIndexPath], animation: MYAnimation) {
        if !syncSections(animation) {
            tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        }
    }
    
    func willAddCellViewModels(viewmodels: [MYCellModel]) {
        setBaseViewDataDelegate(viewmodels)
    }
}

// MARK - MYViewModelDelegate
extension MYTableViewManager : MYViewModelDelegate {
    public func didCallSelectionHandler(view: MYBaseViewProtocol) {
        addSelectedView(view)
    }
   
    public func reloadView(index: Int, section: Int, animation: MYAnimation) {
        let indexPath = NSIndexPath(forRow: index, inSection: section)
        tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
    }
    
    public func reloadHeader(section: Int) {
        if let headerView = tableView?.headerViewForSection(section) as? MYHeaderFooterView {
            if let viewmodel = sections[section].header {
                headerView.configureView(viewmodel)
            }
        }
    }
    
    public func reloadFooter(section: Int) {
        if let footerView = tableView?.footerViewForSection(section) as? MYHeaderFooterView {
            if let viewmodel = sections[section].footer {
                footerView.configureView(viewmodel)
            }
        }
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
   
    /*
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cellData = self.cellViewModelAtIndexPath(indexPath) {
            return cellData.cellHeight
        }
        return 0
    }
    */
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let header = self.sections.my_get(section)?.header {
            return header.isEnabled ? header.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = self.sections.my_get(section)?.header {
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
        if let footer = self.sections.my_get(section)?.footer {
            return footer.isEnabled ? footer.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = self.sections.my_get(section)?.footer {
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

// MARK - UITableViewDataSource
extension MYTableViewManager : UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionCount
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections.my_get(section)?.count ?? 0
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

// MARK - register cell and header/footer view
public extension MYTableViewManager {
    func registerCellClass(cellClass: AnyClass) -> Self {
        return registerCellClasses(cellClass)
    }
    
    func registerCellClasses(cellClasses: AnyClass...) -> Self {
        for cellClass in cellClasses {
            let identifier = String.className(cellClass)
            tableView?.registerClass(cellClass, forCellReuseIdentifier: identifier)
        }
        return self
    }
    
    func registerCellNib(cellClass: AnyClass) -> Self {
        return registerCellNibs(cellClass)
    }
    
    func registerCellNibs(cellClasses: AnyClass...) -> Self {
        for cellClass in cellClasses {
            let identifier = String.className(cellClass)
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        }
        return self
    }
    
    func registerHeaderFooterViewClass(viewClass: AnyClass) -> Self {
        return registerHeaderFooterViewClasses(viewClass)
    }
    
    func registerHeaderFooterViewClasses(viewClasses: AnyClass...) -> Self {
        for viewClass in viewClasses {
            let identifier = String.className(viewClass)
            tableView?.registerClass(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
        }
        return self
    }
    
    func registerHeaderFooterViewNib(viewClass: AnyClass) -> Self {
        return registerHeaderFooterViewNibs(viewClass)
    }
    
    func registerHeaderFooterViewNibs(viewClasses: AnyClass...) -> Self {
        for viewClass in viewClasses {
            let identifier = String.className(viewClass)
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView?.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
        }
        return self
    }
}

// MARK - UIScrollViewDelegate
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

    public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
}

// MARK - private methods
private extension MYTableViewManager {
    func cellViewModelAtIndexPath(indexPath: NSIndexPath) -> MYCellModel? {
        return self.sections.my_get(indexPath.section)?[indexPath.row]
    }
    
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