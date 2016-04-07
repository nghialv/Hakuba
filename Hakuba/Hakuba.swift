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
    public private(set) var sections: [Section] = []
    
    public var loadmoreHandler: (() -> ())?
    public var loadmoreEnabled = false
    public var loadmoreThreshold: CGFloat = 25
    
    private let bumpTracker = BumpTracker()
    private var offscreenCells: [String: Cell] = [:]
    
    public var selectedRows: [NSIndexPath] {
        return tableView?.indexPathsForSelectedRows ?? []
    }
    
    public var visibleRows: [NSIndexPath] {
        return tableView?.indexPathsForVisibleRows ?? []
    }
    
    public var visibleCells: [Cell] {
        return (tableView?.visibleCells as? [Cell]) ?? []
    }

    var currentTopSection = NSNotFound
    var willFloatingSection = NSNotFound
    
    public var sectionsCount: Int {
        return sections.count
    }
    
    public var cellEditable = false
    public var commitEditingHandler: ((UITableViewCellEditingStyle, NSIndexPath) -> ())?
    
    public subscript(index: SectionIndexType) -> Section {
        get {
            return self[index.intValue]
        }
        set {
            self[index.intValue] = newValue
        }
    }
    
    public subscript(index: Int) -> Section {
        get {
            return sections[index]
        }
        set {
            setupSections([newValue], fromIndex: index)
            sections[index] = newValue
        }
    }
    
    subscript(indexPath: NSIndexPath) -> CellModel? {
        return self[indexPath.section][indexPath.row]
    }
    
    public func getCellmodel(indexPath: NSIndexPath) -> CellModel? {
        return sections.get(indexPath.section)?[indexPath.row]
    }
    
    public func getSection(index: Int) -> Section? {
        return sections.get(index)
    }
    
    public func getSection(index: SectionIndexType) -> Section? {
        return getSection(index.intValue)
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
    
    public func bump(animation: Animation = .None) -> Self {
        let changedCount = sections.reduce(0) { $0 + ($1.changed ? 1 : 0) }
        
        if changedCount == 0 {
            switch bumpTracker.getHakubaBumpType() {
            case .Reload:
                tableView?.reloadData()
                
            case let .Insert(indexSet):
                tableView?.insertSections(indexSet, withRowAnimation: animation)
                
            case let .Delete(indexSet):
                tableView?.deleteSections(indexSet, withRowAnimation: animation)
                
            case let .Move(from, to):
                tableView?.moveSection(from, toSection: to)
            }
        } else {
            tableView?.reloadData()
            sections.forEach { $0.didReloadTableView() }
        }
        
        bumpTracker.didBump()
        return self
    }
}


// MARK - UITableView methods

public extension Hakuba {
    func setEditing(editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: animated)
    }
    
    func selectCell(indexPath: NSIndexPath, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        tableView?.selectRowAtIndexPath(indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectCell(indexPath: NSIndexPath, animated: Bool) {
        tableView?.deselectRowAtIndexPath(indexPath, animated: animated)
    }
    
    func deselectAllCells(animated animated: Bool) {
        selectedRows.forEach {
            tableView?.deselectRowAtIndexPath($0, animated: animated)
        }
    }
    
    func getCell(indexPath: NSIndexPath) -> Cell? {
        return tableView?.cellForRowAtIndexPath(indexPath) as? Cell
    }
}

// MARK - Sections

public extension Hakuba {
    // MARK - Reset
    
    func reset(listType: SectionIndexType.Type) -> Self {
        let sections = (0..<listType.count).map { _ in Section() }
        return reset(sections)
    }
    
    func reset() -> Self {
        return reset([])
    }
    
    func reset(section: Section) -> Self {
        return reset([section])
    }
    
    func reset(sections: [Section]) -> Self {
        setupSections(sections, fromIndex: 0)
        self.sections = sections
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    func append(section: Section) -> Self {
        return append([section])
    }
    
    func append(sections: [Section]) -> Self {
        return insert(sections, atIndex: sectionsCount)
    }
    
    // MARK - Insert
    
    func insert(section: Section, atIndex index: Int) -> Self {
        return insert([section], atIndex: index)
    }
    
    func insert(sections: [Section], atIndex index: Int) -> Self {
        guard sections.isNotEmpty else {
            return self
        }
        
        let sIndex = min(max(index, 0), sectionsCount)
        setupSections(sections, fromIndex: sIndex)
        let r = self.sections.insert(sections, atIndex: sIndex)
        bumpTracker.didInsert(Array(r))
        
        return self
    }
    
    func insertBeforeLast(section: Section) -> Self {
        return insertBeforeLast([section])
    }
    
    func insertBeforeLast(sections: [Section]) -> Self {
        let index = max(sections.count - 1, 0)
        return insert(sections, atIndex: index)
    }
    
    // MARK - Remove
    
    func remove(index: Int) -> Self {
        return remove(indexes: [index])
    }
    
    func remove(range: Range<Int>) -> Self {
        let indexes = range.map { $0 }
        return remove(indexes: indexes)
    }
    
    func remove(indexes indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else {
            return self
        }
        
        let sortedIndexes = indexes
            .sort(<)
            .filter { $0 >= 0 && $0 < self.sectionsCount }
        
        var remainSections: [Section] = []
        var i = 0
        
        for j in 0..<sectionsCount {
            if let k = sortedIndexes.get(i) where k == j {
                i += 1
            } else {
                remainSections.append(sections[j])
            }
        }
        
        sections = remainSections
        setupSections(sections, fromIndex: 0)
        
        bumpTracker.didRemove(sortedIndexes)
        
        return self
    }
    
    func removeLast() -> Self {
        let index = sectionsCount - 1
        
        guard index >= 0 else {
            return self
        }
        
        return remove(index)
    }
    
    func remove(section: Section) -> Self {
        let index = section.index
        
        guard index >= 0 && index < sectionsCount else {
            return self
        }
        
        return remove(index)
    }
    
    func removeAll() -> Self {
        return reset()
    }
    
    // MAKR - Move
    
    func move(from: Int, to: Int) -> Self {
        sections.move(fromIndex: from, toIndex: to)
        setupSections([sections[from]], fromIndex: from)
        setupSections([sections[to]], fromIndex: to)
        
        bumpTracker.didMove(from, to: to)
        return self
    }
}

// MARK - SectionDelegate, CellModelDelegate

extension Hakuba: SectionDelegate, CellModelDelegate {
    func bumpMe(type: SectionBumpType, animation: Animation) {
        switch type {
        case .Reload(let indexSet):
            tableView?.reloadSections(indexSet, withRowAnimation: animation)
        
        case .Insert(let indexPaths):
            tableView?.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        
        case .Move(let ori, let des):
            tableView?.moveRowAtIndexPath(ori, toIndexPath: des)
            
        case .Delete(let indexPaths):
            tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
        }
    }
    
    func bumpMe(type: ItemBumpType, animation: Animation) {
        switch type {
        case .Reload(let indexPath):
            tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
            
        case .ReloadHeader:
            break
            
        case .ReloadFooter:
            break
        }
    }
    
    func getOffscreenCell(identifier: String) -> Cell {
        if let cell = offscreenCells[identifier] {
            return cell
        }
        
        if let cell = tableView?.dequeueReusableCellWithIdentifier(identifier) as? Cell {
            offscreenCells[identifier] = cell
            return cell
        }
        return Cell()
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
        (cell as? Cell)?.willDisplay(tableView)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? Cell)?.didEndDisplay(tableView)
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
        return sections.get(section)?.header?.height ?? 0
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sections.get(section)?.header else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(header.reuseIdentifier) as? HeaderFooterView
        headerView?.configureView(header)
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections.get(section)?.footer?.height ?? 0
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sections.get(section)?.footer else {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(footer.reuseIdentifier) as? HeaderFooterView
        footerView?.configureView(footer)
        
        return footerView
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView where section == willFloatingSection else {
            return
        }
        
        view.willDisplay(tableView, section: section)
        view.didChangeFloatingState(true, section: section)
        willFloatingSection = NSNotFound
    }
    
    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
            return
        }
        
        view.willDisplay(tableView, section: section)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
            return
        }
        
        view.didEndDisplaying(tableView, section: section)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
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
            cell = tableView.dequeueReusableCellWithIdentifier(cellmodel.reuseIdentifier, forIndexPath: indexPath) as? Cell else {
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
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections.get(section)?.header?.title
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections.get(section)?.footer?.title
    }
}

// MARK - Private methods

private extension Hakuba {
    func setupSections(sections: [Section], fromIndex start: Int) {
        var start = start
        sections.forEach {
            $0.setup(start, delegate: self)
            start += 1
        }
    }
}