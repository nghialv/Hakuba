//
//  MYTableViewManager.swift
//  MYTableViewManager
//
//  Created by Le Van Nghia on 1/13/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//


import UIKit

public enum MYReloadType {
    case InsertRows(UITableViewRowAnimation)
    case DeleteRows(UITableViewRowAnimation)
    case ReloadRows(UITableViewRowAnimation)
    case ReloadSection
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
    private var heightCalculateCells: [String: MYTableViewCell] = [:]
    
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

    func registerHeadFooterClass(viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        tableView?.registerClass(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterNib(viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView?.registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

// MARK - append/reset/insert/remove/update cell
public extension MYTableViewManager {
    public func appendDataInSection(section: Int, data: MYTableViewCellData, reloadType: MYReloadType) {
        let cellData = [data]
        self.appendDataInSection(section, data: cellData, reloadType: reloadType)
    }
    
    public func appendDataInSection(section: Int, data: [MYTableViewCellData], reloadType: MYReloadType) {
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
                
            case .ReloadSection:
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: .None)
                
            default:
                tableView?.reloadData()
            }
            return
        }
        
        resetDataInSection(section, newData: data, reloadSection: true)
    }
    
    public func resetDataInSection(section: Int, newData: [MYTableViewCellData], reloadSection: Bool = false) {
        self.setBaseViewDataDelegate(newData)
        
        let insertAction = numberOfSections < section + 1
        numberOfSections = max(numberOfSections, section + 1)
        dataSource[section] = newData
        if reloadSection {
            let indexSet = NSIndexSet(index: section)
            if insertAction {
                tableView?.insertSections(indexSet, withRowAnimation: .None)
            } else {
                tableView?.reloadSections(indexSet, withRowAnimation: .None)
            }
        }
    }
    
    public func insertDataInSection(section: Int, data: MYTableViewCellData, atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) -> Bool {
        return self.insertDataInSection(section, data: [data], atRow: row)
    }
    
    public func insertDataInSection(section: Int, data: [MYTableViewCellData], atRow row: Int, reloadType: MYReloadType = .InsertRows(.None)) -> Bool {
        self.setBaseViewDataDelegate(data)
        
        if dataSource[section] == nil {
            self.resetDataInSection(section, newData: [], reloadSection: false)
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
                
            case .ReloadSection:
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: .None)
                
            default:
                tableView?.reloadData()
            }

            return true
        }
        
        return false
    }
    
    func removeDataInSection(section: Int, atRow row: Int, reloadType: MYReloadType = .DeleteRows(.None)) {
        if dataSource[section] != nil {
            dataSource[section]!.removeAtIndex(row)
            
            switch reloadType {
            case .DeleteRows(let animation):
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                
            case .ReloadSection:
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: .None)
                
            default:
                tableView?.reloadData()
            }
        }
    }
    
    func updateUserDataInSection(section: Int, atRow row: Int, userData: AnyObject?, reloadType: MYReloadType = .ReloadRows(.None)) {
        if dataSource[section] != nil  {
            dataSource[section]![row].userData = userData
           
            switch reloadType {
            case .ReloadRows(let animation):
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                
            case .ReloadSection:
                let indexSet = NSIndexSet(index: section)
                tableView?.reloadSections(indexSet, withRowAnimation: .None)
                
            default:
                tableView?.reloadData()
            }
        }
    }
}

// MARK - header/footer 
public extension MYTableViewManager {
    public func setHeaderDataInSection(section: Int, data: MYHeaderFooterViewData) {
        headerViewData[section] = data
    }
    
    public func setFooterDataInSection(section: Int, data: MYHeaderFooterViewData) {
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
        if let cellData = dataSource[indexPath.section]?[indexPath.row] {
            if let h = cellData.calculatedHeight {
                return h
            }
            if heightCalculateCells[cellData.identifier] == nil {
                heightCalculateCells[cellData.identifier] = tableView.dequeueReusableCellWithIdentifier(cellData.identifier) as? MYTableViewCell
            }
            if let cell = heightCalculateCells[cellData.identifier] {
                cell.configureCell(cellData)
                cellData.calculatedHeight = calculateHeightForConfiguredSizingCell(cell)
                return cellData.calculatedHeight!
            }
        }
        return 0
    }
   
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let cellData = dataSource[indexPath.section]?[indexPath.row] {
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
            headerView.setData(data)
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
            footerView.setData(data)
            return footerView
        }
        return nil
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