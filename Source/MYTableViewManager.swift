//
//  MYTableViewManager.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//


import UIKit

private extension Array {
    mutating func insert(newArray: Array, atIndex index: Int) {
        let left = self[0..<max(0, index)]
        let right = index > count ? [] : self[index..<count]
        self = left + newArray + right
    }
    
    func get(index: Int) -> T? {
        return 0 <= index && index < count ? self[index] : nil
    }
}

public enum MYReloadType {
    case InsertRows(UITableViewRowAnimation)
    case DeleteRows(UITableViewRowAnimation)
    case ReloadRows(UITableViewRowAnimation)
    case ReloadSection(UITableViewRowAnimation)
    case ReloadTableView
    case None
}

@objc public protocol MYTableViewManagerDelegate : class {
    optional func scrollViewDidScroll(scrollView: UIScrollView)
    optional func scrollViewWillBeginDecelerating(scrollView: UIScrollView)
    optional func scrollViewWillBeginDragging(scrollView: UIScrollView)
}

public class MYTableViewManager : NSObject {
    typealias MYTableViewCellDataList = [MYTableViewCellData]
    weak var delegate: MYTableViewManagerDelegate?
    
    private weak var tableView: UITableView?
    private var dataSource: [Int: MYTableViewCellDataList] = [:]
    private var headerViewData: [Int: MYHeaderFooterViewData] = [:]
    private var footerViewData: [Int: MYHeaderFooterViewData] = [:]
    private var numberOfSections: Int = 0
    private var selectedCells = [MYBaseViewProtocol]()
    private var heightCalculationCells: [String: MYTableViewCell] = [:]
    private var currentTopSection = 0
    private var willFloatingSection = -1
    var loadmoreHandler: (() -> ())?
    var loadmoreEnabled = false
    var loadmoreThreshold: CGFloat = 25
    
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
        dataSource = [:]
        headerViewData = [:]
        footerViewData = [:]
        numberOfSections = 0
        selectedCells = []
        heightCalculationCells = [:]
        currentTopSection = 0
        willFloatingSection = -1
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

// MARK - Append
public extension MYTableViewManager {
    func appendData(data: MYTableViewCellData, inSection section: Int, reloadType: MYReloadType = .InsertRows(.None)) {
        let cellData = [data]
        self.appendData(cellData, inSection: section, reloadType: reloadType)
    }
    
    func appendData(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType = .InsertRows(.None)) {
        if self.dataSource.indexForKey(section) != nil {
            self.setBaseViewDataDelegate(data)
            self.dataSource[section]! += data
            
            switch reloadType {
            case .InsertRows(let animation):
                let startRowIndex = self.dataSource[section]!.count - data.count
                let endRowIndex = startRowIndex + data.count
                let indexPaths = (startRowIndex..<endRowIndex).map { index -> NSIndexPath in
                    return NSIndexPath(forRow: index, inSection: section)
                }
                self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
                
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                self.tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
            case .None:
                break
                
            default:
                self.tableView?.reloadData()
            }
            return
        }
        self.resetWithData(data, inSection: section, reloadType: reloadType)
    }
}

// MARK - Reset
public extension MYTableViewManager {
    func resetWithData(data: MYTableViewCellData, inSection section: Int, reloadType: MYReloadType = .ReloadSection(.None)) {
        resetWithData([data], inSection: section, reloadType: reloadType)
    }
    
    func resetWithData(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType = .ReloadSection(.None)) {
        self.setBaseViewDataDelegate(data)
    
        let length = section + 1 - self.numberOfSections
        let insertSections: NSIndexSet? = length > 0 ? NSIndexSet(indexesInRange: NSMakeRange(self.numberOfSections, length)) : nil
        self.numberOfSections = max(self.numberOfSections, section + 1)
        self.dataSource[section] = data
        
        switch reloadType {
        case .ReloadSection(let animation):
            if insertSections != nil {
                self.tableView?.insertSections(insertSections!, withRowAnimation: animation)
            } else {
                let indexSet = NSIndexSet(index: section)
                self.tableView?.reloadSections(indexSet, withRowAnimation: animation)
            }
            
        case .None:
            break
        
        default:
            self.tableView?.reloadData()
        }
    }
}

// MARK - Insert
public extension MYTableViewManager {
    func insertData(data: MYTableViewCellData, inSection section: Int, atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) {
        self.insertData([data], inSection: section, atRow: row)
    }
    
    func insertData(data: [MYTableViewCellData], inSection section: Int, atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) {
        self.setBaseViewDataDelegate(data)
        
        if self.dataSource[section] == nil {
            var rt: MYReloadType = .None
            switch reloadType {
            case .None:
                rt = .None
            default:
                rt = .ReloadSection(.None)
            }
            return self.resetWithData(data, inSection: section, reloadType: rt)
        }
        if row < 0 ||  row > self.dataSource[section]!.count {
            return
        }
        self.dataSource[section]?.insert(data, atIndex: row)
            
        switch reloadType {
        case .InsertRows(let animation):
            let startRowIndex = row
            let endRowIndex = startRowIndex + data.count
            let indexPaths = (startRowIndex..<endRowIndex).map { index -> NSIndexPath in
                return NSIndexPath(forRow: index, inSection: section)
            }
            self.tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
                
        case .ReloadSection(let animation):
            let indexSet = NSIndexSet(index: section)
            self.tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
        case .None:
            break
                
        default:
            self.tableView?.reloadData()
        }
    }
    
    func insertDataBeforeLastRow(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType = .InsertRows(.None)) {
        let lastRow = max((self.dataSource[section]?.count ?? 0) - 1, 0)
        self.insertData(data, inSection: section, atRow: lastRow, reloadType: reloadType)
    }
}

// MARK - Remove
public extension MYTableViewManager {
    func removeDataInSection(section: Int, atRow row: Int, reloadType: MYReloadType = .DeleteRows(.None)) {
        removeDataInSection(section, inRange: (row...row), reloadType: reloadType)
    }
  
    func removeLastDataInSection(section: Int, reloadType: MYReloadType = .DeleteRows(.None)) {
        let lastIndex = (dataSource[section]?.count ?? 0) - 1
        removeDataInSection(section, atRow: lastIndex, reloadType: reloadType)
    }
    
    func removeDataInSection(section: Int, inRange range: Range<Int>, reloadType: MYReloadType = .DeleteRows(.None)) {
        if self.dataSource[section] != nil {
            let start = max(0, range.startIndex)
            let end = min(self.dataSource[section]!.count, range.endIndex)
            let safeRange = Range(start: start, end: end)
            self.dataSource[section]!.removeRange(safeRange)
    
            switch reloadType {
            case .DeleteRows(let animation):
                let indexPaths = safeRange.map { NSIndexPath(forRow: $0, inSection: section) }
                self.tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
            
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                self.tableView?.reloadSections(indexSet, withRowAnimation: animation)
        
            case .None:
                break
            
            default:
                self.tableView?.reloadData()
            }
        }
    }
}

// MARK - Update user info
public extension MYTableViewManager {
    func updateUserData(userData: AnyObject?, inSection section: Int, atRow row: Int, reloadType: MYReloadType = .ReloadRows(.None)) {
        if self.dataSource[section] != nil  {
            if let data = self.dataSource[section]?.get(row) {
                data.userData = userData
                data.calculatedHeight = nil
            
                switch reloadType {
                case .ReloadRows(let animation):
                    let indexPath = NSIndexPath(forRow: row, inSection: section)
                    self.tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                
                case .ReloadSection(let animation):
                    let indexSet = NSIndexSet(index: section)
                    self.tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
                case .None:
                    break
                    
                default:
                    self.tableView?.reloadData()
                }
            }
        }
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
    
    func numberRowsInSection(section: Int) -> Int {
        return dataSource[section]?.count ?? 0
    }
    
    func cellForRowAtSection(section: Int, row: Int) -> MYTableViewCell? {
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        return tableView?.cellForRowAtIndexPath(indexPath) as? MYTableViewCell
    }
}

// MARK - header/footer 
public extension MYTableViewManager {
    func setHeaderData(data: MYHeaderFooterViewData, inSection section: Int) {
        headerViewData[section] = data
    }
    
    func setFooterData(data: MYHeaderFooterViewData, inSection section: Int) {
        footerViewData[section] = data
    }
    
    func setHeaderViewInSection(section: Int, hidden: Bool) {
        if let data = headerViewData[section] {
            data.isEnabled = !hidden
        }
    }
    
    func setFooterViewInSection(section: Int, hidden: Bool) {
        if let data = footerViewData[section] {
            data.isEnabled = !hidden
        }
    }
}

// MARK - private methods
private extension MYTableViewManager {
    func addSelectedView(view: MYBaseViewProtocol) {
        deselectAllCells()
        selectedCells = [view]
    }
    
    func setBaseViewDataDelegate(dataList: [MYBaseViewData]) {
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
        if let cellData = dataSource[indexPath.section]?.get(indexPath.row) {
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
        if let cellData = dataSource[indexPath.section]?.get(indexPath.row) {
            return cellData.cellHeight
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let data = headerViewData[section] {
            return data.isEnabled ? data.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let data = headerViewData[section] {
            if !data.isEnabled {
                return nil
            }
            let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(data.identifier) as MYHeaderFooterView
            headerView.configureView(data)
            return headerView
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let data = footerViewData[section] {
            return data.isEnabled ? data.viewHeight : 0
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let data = footerViewData[section] {
            if !data.isEnabled {
                return nil
            }
            let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(data.identifier) as MYHeaderFooterView
            footerView.configureView(data)
            return footerView
        }
        return nil
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellData = dataSource[indexPath.section]?.get(indexPath.row) {
            if let myCell = cell as? MYTableViewCell {
                myCell.willAppear(cellData)
            }
        }
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellData = dataSource[indexPath.section]?.get(indexPath.row) {
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
        return dataSource[section]?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellData = dataSource[indexPath.section]![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellData.identifier, forIndexPath: indexPath) as MYTableViewCell
        cell.configureCell(cellData)
        return cell
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