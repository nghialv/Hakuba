//
//  Hakuba.swift
//  Example
//
//  Created by Le VanNghia on 3/4/16.
//
//

import UIKit

final public class Hakuba: NSObject {
    weak var tableView: UITableView?
    public weak var delegate: HakubaDelegate?
    public private(set) var sections: [HASection] = []
    
    public var loadmoreHandler: (() -> ())?
    public var loadmoreEnabled = false
    public var loadmoreThreshold: CGFloat = 25
    
    private let bumpTracker = HABumpTracker()
    private var offscreenCells: [String: HACell] = [:]
    
    var currentTopSection = 0
    var willFloatingSection = -1
    
    public var sectionsCount: Int {
        return sections.count
    }
    
    public var cellEditable = false
    public var commitEditingHandler: ((UITableViewCellEditingStyle, NSIndexPath) -> ())?
    
    public subscript(index: SectionIndex) -> HASection {
        get {
            return self[index.intValue]
        }
        set {
            self[index.intValue] = newValue
        }
    }
    
    public subscript(index: Int) -> HASection {
        get {
            if let section = sections.get(index) {
                return section
            }
            
            let newSections = (sectionsCount...index).map { _ in HASection() }
            setupSections(newSections, fromIndex: sectionsCount)
            
            sections += newSections
            return sections[index]
        }
        set {
            if index < sectionsCount {
                sections[index] = newValue
                setupSections([newValue], fromIndex: index)
            } else {
                let newSections = (sectionsCount..<index).map { _ in HASection() } + [newValue]
                setupSections(newSections, fromIndex: sectionsCount)
                sections += newSections
            }
        }
    }
    
    subscript(indexPath: NSIndexPath) -> HACellModel? {
        return self[indexPath.section][indexPath.row]
    }
    
    public func getCellmodel(indexPath: NSIndexPath) -> HACellModel? {
        return sections.get(indexPath.section)?[indexPath.row]
    }
    
    public init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    deinit {
        tableView?.delegate = nil
        tableView?.dataSource = nil
    }
}


// MARK - UITableView methods

public extension Hakuba {
    func setEditing(editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: animated)
    }
    
    func deselectCell(indexPath: NSIndexPath, animated: Bool) {
        tableView?.deselectRowAtIndexPath(indexPath, animated: animated)
    }
    
    func getCell(indexPath: NSIndexPath) -> HACell? {
        return tableView?.cellForRowAtIndexPath(indexPath) as? HACell
    }
}

// MARK - Sections

public extension Hakuba {
    // MARK - Reset
    
    func reset() -> Self {
        return reset([])
    }
    
    func reset(section: HASection) -> Self {
        return reset([section])
    }
    
    func reset(sections: [HASection]) -> Self {
        return self
    }
    
    // MARK - Append
    
    func append(section: HASection) -> Self {
        return append([section])
    }
    
    func append(sections: [HASection]) -> Self {
        return insert(sections, atIndex: sectionsCount)
    }
    
    // MARK - Insert
    
    func insert(section: HASection, atIndex index: Int) -> Self {
        return insert([section], atIndex: index)
    }
    
    func insert(sections: [HASection], atIndex index: Int) -> Self {
        return self
    }
    
    func insertBeforeLast(section: HASection) -> Self {
        return insertBeforeLast([section])
    }
    
    func insertBeforeLast(sections: [HASection]) -> Self {
        let index = max(sections.count - 1, 0)
        return insert(sections, atIndex: index)
    }
    
    // MARK - Remove
    
    func remove(indexes: [Int]) -> Self {
        return self
    }
    
    func removeSection(index: Int) -> Self {
        return remove([index])
    }
    
    func removeLast() -> Self {
        let index = sectionsCount - 1
        if index >= 0 {
            removeSection(index)
        }
        return self
    }
    
    func remove(section: HASection) -> Self {
        return self
    }
}

// MARK - HASectionDelegate, HACellModelDelegate

extension Hakuba: HASectionDelegate, HACellModelDelegate {
    func bumpMe(type: SectionBumpType, animation: HAAnimation) {
        
    }
    
    func bumpMe(type: ItemBumpType) {
        
    }
    
    func getOffscreenCell(identifier: String) -> HACell {
        return HACell()
    }
    
    func tableViewWidth() -> CGFloat {
        return tableView?.bounds.width ?? 0
    }
}

// MARK - UITableViewDelegate cell

extension Hakuba: UITableViewDelegate {
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return getCellmodel(indexPath)?.height ?? 0
    }
    
//  public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//  }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return getCell(indexPath)?.willSelect(tableView, indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellmodel = getCellmodel(indexPath), cell = getCell(indexPath) else {
            return
        }
        
        cellmodel.didSelect(cell)
        cell.didSelect(tableView)
    }
    
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return getCell(indexPath)?.willDeselect(tableView, indexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        getCell(indexPath)?.didDeselect(tableView)
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? HACell)?.willDisplay(tableView)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? HACell)?.didEndDisplay(tableView)
    }
    
    public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return getCellmodel(indexPath)?.editingStyle ?? .None
    }
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return getCellmodel(indexPath)?.shouldHighlight ?? true
    }
    
    public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        getCell(indexPath)?.didHighlight(tableView)
    }
    
    public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        getCell(indexPath)?.didUnhighlight(tableView)
    }
}

// MARK - UITableViewDelegate header-footer

extension Hakuba {
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = sections.get(section)?.header where header.isEnabled else {
            return 0
        }
        
        return header.height
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sections.get(section)?.header where header.isEnabled else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(header.reuseIdentifier) as? HAHeaderFooterView
        headerView?.configureView(header)
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let footer = sections.get(section)?.footer where footer.isEnabled else {
            return 0
        }
        
        return footer.height
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sections.get(section)?.footer where footer.isEnabled else {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footer.reuseIdentifier) as? HAHeaderFooterView
        footerView?.configureView(footer)
        
        return footerView
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HAHeaderFooterView where section == willFloatingSection else {
            return
        }
        
        view.willDisplay(tableView, section: section)
        view.didChangeFloatingState(true, section: section)
        willFloatingSection = -1
    }
    
    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HAHeaderFooterView else {
            return
        }
        
        view.willDisplay(tableView, section: section)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HAHeaderFooterView else {
            return
        }
        
        view.didEndDisplaying(tableView, section: section)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HAHeaderFooterView else {
            return
        }
        
        view.didEndDisplaying(tableView, section: section)
    }
}

// MARK - UITableViewDataSource

extension Hakuba: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.get(section)?.count ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellmodel = getCellmodel(indexPath),
            cell = tableView.dequeueReusableCellWithIdentifier(cellmodel.reuseIdentifier, forIndexPath: indexPath) as? HACell else {
            return UITableViewCell()
        }
        
        cell.configureCell(cellmodel)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        commitEditingHandler?(editingStyle, indexPath)
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let cellmodel = getCellmodel(indexPath) else {
            return false
        }
        
        return cellmodel.editable || cellEditable
    }
}

// MARK - Private methods

private extension Hakuba {
    func setupSections(sections: [HASection], var fromIndex start: Int) {
        sections.forEach {
            $0.setup(start++, delegate: self)
        }
    }
}