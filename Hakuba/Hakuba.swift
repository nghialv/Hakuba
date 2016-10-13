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
    public fileprivate(set) var sections: [Section] = []
    
    public var loadmoreHandler: (() -> ())?
    public var loadmoreEnabled = false
    public var loadmoreThreshold: CGFloat = 25
    
    fileprivate let bumpTracker = BumpTracker()
    fileprivate var offscreenCells: [String: Cell] = [:]
    
    public var selectedRows: [IndexPath] {
        return tableView?.indexPathsForSelectedRows ?? []
    }
    
    public var visibleRows: [IndexPath] {
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
    public var commitEditingHandler: ((UITableViewCellEditingStyle, IndexPath) -> ())?
    
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
    
    subscript(indexPath: IndexPath) -> CellModel? {
        return self[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    public func getCellmodel(_ indexPath: IndexPath) -> CellModel? {
        return sections.get((indexPath as NSIndexPath).section)?[(indexPath as NSIndexPath).row]
    }
    
    public func getSection(_ index: Int) -> Section? {
        return sections.get(index)
    }
    
    public func getSection(_ index: SectionIndexType) -> Section? {
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
    
    public func bump(_ animation: Animation = .none) -> Self {
        let changedCount = sections.reduce(0) { $0 + ($1.changed ? 1 : 0) }
        
        if changedCount == 0 {
            switch bumpTracker.getHakubaBumpType() {
            case .reload:
                tableView?.reloadData()
                
            case let .insert(indexSet):
                tableView?.insertSections(indexSet, with: animation)
                
            case let .delete(indexSet):
                tableView?.deleteSections(indexSet, with: animation)
                
            case let .move(from, to):
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
    func setEditing(_ editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: animated)
    }
    
    func selectCell(_ indexPath: IndexPath, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        tableView?.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectCell(_ indexPath: IndexPath, animated: Bool) {
        tableView?.deselectRow(at: indexPath, animated: animated)
    }
    
    func deselectAllCells(animated: Bool) {
        selectedRows.forEach {
            tableView?.deselectRow(at: $0, animated: animated)
        }
    }
    
    func getCell(_ indexPath: IndexPath) -> Cell? {
        return tableView?.cellForRow(at: indexPath) as? Cell
    }
}

// MARK - Sections

public extension Hakuba {
    // MARK - Reset
    
    func reset(_ listType: SectionIndexType.Type) -> Self {
        let sections = (0..<listType.count).map { _ in Section() }
        return reset(sections)
    }
    
    func reset() -> Self {
        return reset([])
    }
    
    func reset(_ section: Section) -> Self {
        return reset([section])
    }
    
    func reset(_ sections: [Section]) -> Self {
        setupSections(sections, fromIndex: 0)
        self.sections = sections
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    func append(_ section: Section) -> Self {
        return append([section])
    }
    
    func append(_ sections: [Section]) -> Self {
        return insert(sections, atIndex: sectionsCount)
    }
    
    // MARK - Insert
    
    func insert(_ section: Section, atIndex index: Int) -> Self {
        return insert([section], atIndex: index)
    }
    
    func insert(_ sections: [Section], atIndex index: Int) -> Self {
        guard sections.isNotEmpty else {
            return self
        }
        
        let sIndex = min(max(index, 0), sectionsCount)
        setupSections(sections, fromIndex: sIndex)
        let r = self.sections.insert(sections, atIndex: sIndex)
        bumpTracker.didInsert(Array(r))
        
        return self
    }
    
    func insertBeforeLast(_ section: Section) -> Self {
        return insertBeforeLast([section])
    }
    
    func insertBeforeLast(_ sections: [Section]) -> Self {
        let index = max(sections.count - 1, 0)
        return insert(sections, atIndex: index)
    }
    
    // MARK - Remove
    
    func remove(_ index: Int) -> Self {
        return remove(indexes: [index])
    }
    
    func remove(_ range: CountableClosedRange<Int>) -> Self {
        let indexes = range.map { $0 }
        return remove(indexes: indexes)
    }
    
    func remove(indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else {
            return self
        }
        
        let sortedIndexes = indexes
            .sorted(by: <)
            .filter { $0 >= 0 && $0 < self.sectionsCount }
        
        var remainSections: [Section] = []
        var i = 0
        
        for j in 0..<sectionsCount {
            if let k = sortedIndexes.get(i) , k == j {
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
    
    func remove(_ section: Section) -> Self {
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
    
    func move(_ from: Int, to: Int) -> Self {
        sections.move(fromIndex: from, toIndex: to)
        setupSections([sections[from]], fromIndex: from)
        setupSections([sections[to]], fromIndex: to)
        
        bumpTracker.didMove(from, to: to)
        return self
    }
}

// MARK - SectionDelegate, CellModelDelegate

extension Hakuba: SectionDelegate, CellModelDelegate {
    func bumpMe(_ type: SectionBumpType, animation: Animation) {
        switch type {
        case .reload(let indexSet):
            tableView?.reloadSections(indexSet, with: animation)
        
        case .insert(let indexPaths):
            tableView?.insertRows(at: indexPaths, with: animation)
        
        case .move(let ori, let des):
            tableView?.moveRow(at: ori, to: des)
            
        case .delete(let indexPaths):
            tableView?.deleteRows(at: indexPaths, with: animation)
        }
    }
    
    func bumpMe(_ type: ItemBumpType, animation: Animation) {
        switch type {
        case .reload(let indexPath):
            tableView?.reloadRows(at: [indexPath], with: animation)
            
        case .reloadHeader:
            break
            
        case .reloadFooter:
            break
        }
    }
    
    func getOffscreenCell(_ identifier: String) -> Cell {
        if let cell = offscreenCells[identifier] {
            return cell
        }
        
        if let cell = tableView?.dequeueReusableCell(withIdentifier: identifier) as? Cell {
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
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellmodel(indexPath)?.height ?? 0
    }
    
//  public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//  }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return getCell(indexPath)?.willSelect(tableView, indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellmodel = getCellmodel(indexPath), let cell = getCell(indexPath) else {
            return
        }
        
        cellmodel.didSelect(cell)
        cell.didSelect(tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return getCell(indexPath)?.willDeselect(tableView, indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        getCell(indexPath)?.didDeselect(tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.willDisplay(tableView)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.didEndDisplay(tableView)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return getCellmodel(indexPath)?.editingStyle ?? .none
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return getCellmodel(indexPath)?.shouldHighlight ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        getCell(indexPath)?.didHighlight(tableView)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        getCell(indexPath)?.didUnhighlight(tableView)
    }
}

// MARK - UITableViewDelegate header-footer

extension Hakuba {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections.get(section)?.header?.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sections.get(section)?.header else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.reuseIdentifier) as? HeaderFooterView
        headerView?.configureView(header)
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections.get(section)?.footer?.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sections.get(section)?.footer else {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.reuseIdentifier) as? HeaderFooterView
        footerView?.configureView(footer)
        
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView , section == willFloatingSection else {
            return
        }
        
        view.willDisplay(tableView, section: section)
        view.didChangeFloatingState(true, section: section)
        willFloatingSection = NSNotFound
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
            return
        }
        
        view.willDisplay(tableView, section: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
            return
        }
        
        view.didEndDisplaying(tableView, section: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else {
            return
        }
        
        view.didEndDisplaying(tableView, section: section)
    }
}

// MARK - UITableViewDataSource

extension Hakuba: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.get(section)?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellmodel = getCellmodel(indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellmodel.reuseIdentifier, for: indexPath) as? Cell else {
            return UITableViewCell()
        }
        
        cell.configureCell(cellmodel)
      
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        commitEditingHandler?(editingStyle, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let cellmodel = getCellmodel(indexPath) else {
            return false
        }
        
        return cellmodel.editable || cellEditable
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections.get(section)?.header?.title
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections.get(section)?.footer?.title
    }
}

// MARK - Private methods

private extension Hakuba {
    func setupSections(_ sections: [Section], fromIndex start: Int) {
        var start = start
        sections.forEach {
            $0.setup(start, delegate: self)
            start += 1
        }
    }
}
