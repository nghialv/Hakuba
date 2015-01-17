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
    case ReleadTableView
}

public class MYTableViewManager : NSObject {
    typealias MYTableViewCellDataList = [MYTableViewCellData]
    
    private weak var tableView: UITableView?
    private var dataSource: [Int: MYTableViewCellDataList] = [:]
    private var headerViewData: [Int: MYHeaderFooterViewData] = [:]
    private var footerViewData: [Int: MYHeaderFooterViewData] = [:]
    private var numberOfSections: Int = 0
    private var selectedCells = [MYBaseViewProtocol]()
    private var heightCalculationCells: [String: MYTableViewCell] = [:]
    
    subscript(index: Int) -> [MYTableViewCellData] {
        get {
            if dataSource.indexForKey(index) != nil {
                return dataSource[index]!
            } else {
                numberOfSections = max(numberOfSections, index + 1)
                dataSource[index] = []
                return dataSource[index]!
            }
        }
        set(newValue) {
            dataSource[index] = newValue
        }
    }
   
    init(tableView: UITableView) {
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

// MARK - append/reset/insert/remove/update cell
public extension MYTableViewManager {
    public func appendData(data: MYTableViewCellData, inSection section: Int, reloadType: MYReloadType) {
        let cellData = [data]
        self.appendData(cellData, inSection: section, reloadType: reloadType)
    }
    
    public func appendData(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType) {
        if dataSource.indexForKey(section) != nil {
            self.setBaseViewDataDelegate(data)
            dataSource[section]! += data
            
            switch reloadType {
            case .InsertRows(let animation):
                let startRowIndex = dataSource[section]!.count - data.count
                let endRowIndex = startRowIndex + data.count
                let indexPaths = (startRowIndex..<endRowIndex).map { index -> NSIndexPath in
                    return NSIndexPath(forRow: index, inSection: section)
                }
                tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
                
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
            default:
                tableView?.reloadData()
            }
            return
        }
        
        resetWithData(data, inSection: section, reloadType: reloadType)
    }
   
    public func resetWithData(data: MYTableViewCellData, inSection section: Int, reloadType: MYReloadType = .ReloadSection(.None)) {
        resetWithData([data], inSection: section, reloadType: reloadType)
    }
    
    public func resetWithData(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType = .ReloadSection(.None)) {
        self.setBaseViewDataDelegate(data)
       
        let insertSection = numberOfSections < section + 1
        numberOfSections = max(numberOfSections, section + 1)
        dataSource[section] = data
        switch reloadType {
        case .ReloadSection(let animation):
            let indexSet = NSIndexSet(index: section)
            if insertSection {
                tableView?.insertSections(indexSet, withRowAnimation: animation)
            } else {
                tableView?.reloadSections(indexSet, withRowAnimation: animation)
            }
        default:
            tableView?.reloadData()
        }
    }
    
    public func insertData(data: MYTableViewCellData, inSection section: Int, atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) -> Bool {
        return self.insertData([data], inSection: section, atRow: row)
    }
    
    public func insertData(data: [MYTableViewCellData], inSection section: Int, atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) -> Bool {
        self.setBaseViewDataDelegate(data)
        
        if dataSource[section] == nil {
            self.resetWithData([], inSection: section, reloadType: .ReloadSection(.None))
        }
       
        if (row >= 0) && (row <= dataSource[section]!.count) {
            dataSource[section]?.insert(data, atIndex: row)
            
            switch reloadType {
            case .InsertRows(let animation):
                let startRowIndex = row
                let endRowIndex = startRowIndex + data.count
                let indexPaths = (startRowIndex..<endRowIndex).map { index -> NSIndexPath in
                    return NSIndexPath(forRow: index, inSection: section)
                }
                tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
                
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
            default:
                tableView?.reloadData()
            }

            return true
        }
        
        return false
    }
    
    public func insertDataBeforeLastRow(data: [MYTableViewCellData], inSection section: Int, reloadType: MYReloadType = .InsertRows(.None)) -> Bool {
        if dataSource[section] != nil {
            let lastRow = max(dataSource[section]!.count - 1, 0)
            return insertData(data, inSection: section, atRow: lastRow, reloadType: reloadType)
        }
        return false
    }
    
    func removeDataInSection(section: Int, atRow row: Int, reloadType: MYReloadType = .DeleteRows(.None)) {
        removeDataInSection(section, inRange: (row...row), reloadType: reloadType)
    }
  
    func removeLastDataInSection(section: Int, reloadType: MYReloadType = .DeleteRows(.None)) {
        let lastIndex = (dataSource[section]?.count ?? 0) - 1
        removeDataInSection(section, atRow: lastIndex, reloadType: reloadType)
    }
    
    func removeDataInSection(section: Int, inRange range: Range<Int>, reloadType: MYReloadType = .DeleteRows(.None)) {
        if dataSource[section] != nil {
            let start = max(0, range.startIndex)
            let end = min(dataSource[section]!.count, range.endIndex)
            let safeRange = Range(start: start, end: end)
            dataSource[section]!.removeRange(safeRange)
        
            switch reloadType {
            case .DeleteRows(let animation):
                let indexPaths = safeRange.map { NSIndexPath(forRow: $0, inSection: section) }
                tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
                
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
            default:
                tableView?.reloadData()
            }
        }
    }
    
    func updateUserData(userData: AnyObject?, inSection section: Int, atRow row: Int, reloadType: MYReloadType = .ReloadRows(.None)) {
        if dataSource[section] != nil  {
            dataSource[section]![row].userData = userData
            dataSource[section]![row].calculatedHeight = nil
            
            switch reloadType {
            case .ReloadRows(let animation):
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                
            case .ReloadSection(let animation):
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: animation)
                
            default:
                tableView?.reloadData()
            }
        }
    }
}

// MARK - header/footer 
public extension MYTableViewManager {
    public func setHeaderData(data: MYHeaderFooterViewData, inSection section: Int) {
        headerViewData[section] = data
    }
    
    public func setFooterData(data: MYHeaderFooterViewData, inSection section: Int) {
        footerViewData[section] = data
    }
    
    public func enableHeaderViewInSection(section: Int) {
        if let data = headerViewData[section] {
            data.isEnabled = true
        }
    }
    
    public func disableHeaderViewInSection(section: Int) {
        if let data = headerViewData[section] {
            data.isEnabled = false
        }
    }
    
    public func enableFooterViewInSection(section: Int) {
        if let data = footerViewData[section] {
            data.isEnabled = true
        }
    }
    
    public func disableFooterViewInSection(section: Int) {
        if let data = footerViewData[section] {
            data.isEnabled = false
        }
    }
}

// MARK - private methods
private extension MYTableViewManager {
    private func addSelectedView(view: MYBaseViewProtocol) {
        deselectAllCells()
        selectedCells = [view]
    }
    
    private func setBaseViewDataDelegate(dataList: [MYBaseViewData]) {
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