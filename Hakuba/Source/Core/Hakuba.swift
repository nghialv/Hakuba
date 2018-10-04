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
    public var commitEditingHandler: ((UITableViewCell.EditingStyle, IndexPath) -> ())?
    
    public subscript<T: RawRepresentable & SectionIndexType>(index: T) -> Section {
        get {
            return self[index.rawValue]
        }
        set {
            self[index.rawValue] = newValue
        }
    }
    
    public subscript(index: Int) -> Section {
        get {
            return sections[index]
        }
        set {
            setupSections([newValue], from: index)
            sections[index] = newValue
        }
    }
    
    subscript(indexPath: IndexPath) -> CellModel? {
        return self[indexPath.section][indexPath.row]
    }
    
    public func getCellmodel(at indexPath: IndexPath) -> CellModel? {
        return sections.get(at: indexPath.section)?[indexPath.row]
    }
    
    public func getSection(at index: Int) -> Section? {
        return sections.get(at: index)
    }
    
    public func getSection<T: RawRepresentable & SectionIndexType>(at index: T) -> Section? {
        return getSection(at: index.rawValue)
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
    
    @discardableResult
    public func bump(_ animation: UITableView.RowAnimation = .none) -> Self {
        let changedCount = sections.reduce(0) { $0 + ($1.isChanged ? 1 : 0) }
        
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
    
    func selectCell(at indexPath: IndexPath, animated: Bool, scrollPosition: UITableView.ScrollPosition) {
        tableView?.selectRow(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    func deselectCell(at indexPath: IndexPath, animated: Bool) {
        tableView?.deselectRow(at: indexPath, animated: animated)
    }
    
    func deselectAllCells(animated: Bool) {
        selectedRows.forEach {
            tableView?.deselectRow(at: $0, animated: animated)
        }
    }
    
    func cellForRow(at indexPath: IndexPath) -> Cell? {
        return tableView?.cellForRow(at: indexPath) as? Cell
    }
}

// MARK - Sections

public extension Hakuba {
    // MARK - Reset
    
    @discardableResult
    func reset<T: RawRepresentable & SectionIndexType>(_ listType: T.Type) -> Self {
        let sections = (0..<listType.allCases.count).map { _ in Section() }
        return reset(sections)
    }
    
    @discardableResult
    func reset() -> Self {
        return reset([])
    }
    
    @discardableResult
    func reset(_ section: Section) -> Self {
        return reset([section])
    }
    
    @discardableResult
    func reset(_ sections: [Section]) -> Self {
        setupSections(sections, from: 0)
        self.sections = sections
        bumpTracker.didReset()
        return self
    }
    
    // MARK - Append
    
    @discardableResult
    func append(_ section: Section) -> Self {
        return append([section])
    }
    
    @discardableResult
    func append(_ sections: [Section]) -> Self {
        return insert(sections, at: sectionsCount)
    }
    
    // MARK - Insert
    
    @discardableResult
    func insert(_ section: Section, at index: Int) -> Self {
        return insert([section], at: index)
    }
    
    @discardableResult
    func insert(_ sections: [Section], at index: Int) -> Self {
        guard sections.isNotEmpty else { return self }
        
        let sIndex = min(max(index, 0), sectionsCount)
        setupSections(sections, from: sIndex)
        let r = self.sections.insert(sections, at: sIndex)
        bumpTracker.didInsert(indexes: Array(r.lowerBound...r.upperBound))
        
        return self
    }
    
    @discardableResult
    func insertBeforeLast(_ section: Section) -> Self {
        return insertBeforeLast([section])
    }
    
    @discardableResult
    func insertBeforeLast(_ sections: [Section]) -> Self {
        let index = max(sections.count - 1, 0)
        return insert(sections, at: index)
    }
    
    // MARK - Remove
    
    @discardableResult
    func remove(at index: Int) -> Self {
        return remove(at: [index])
    }
    
    @discardableResult
    func remove(range: CountableRange<Int>) -> Self {
        return remove(at: range.map { $0 })
    }
    
    @discardableResult
    func remove(range: CountableClosedRange<Int>) -> Self {
        return remove(at: range.map { $0 })
    }
    
    @discardableResult
    func remove(at indexes: [Int]) -> Self {
        guard indexes.isNotEmpty else { return self }
        
        let sortedIndexes = indexes
            .sorted(by: <)
            .filter { $0 >= 0 && $0 < self.sectionsCount }
        
        var remainSections: [Section] = []
        var i = 0
        
        for j in 0..<sectionsCount {
            if let k = sortedIndexes.get(at: i), k == j {
                i += 1
            } else {
                remainSections.append(sections[j])
            }
        }
        
        sections = remainSections
        setupSections(sections, from: 0)
        
        bumpTracker.didRemove(indexes: sortedIndexes)
        
        return self
    }
    
    @discardableResult
    func removeLast() -> Self {
        let index = sectionsCount - 1
        
        guard index >= 0 else { return self }
        
        return remove(at: index)
    }
    
    @discardableResult
    func remove(_ section: Section) -> Self {
        let index = section.index
        
        guard index >= 0 && index < sectionsCount else { return self }
        
        return remove(at: index)
    }
    
    @discardableResult
    func removeAll() -> Self {
        return reset()
    }
    
    // MAKR - Move
    
    @discardableResult
    func move(from fromIndex: Int, to toIndex: Int) -> Self {
        sections.move(from: fromIndex, to: toIndex)
        setupSections([sections[fromIndex]], from: fromIndex)
        setupSections([sections[toIndex]], from: toIndex)
        
        bumpTracker.didMove(from: fromIndex, to: toIndex)
        return self
    }
}

// MARK - SectionDelegate, CellModelDelegate

extension Hakuba: SectionDelegate, CellModelDelegate {
    func bumpMe(with type: SectionBumpType, animation: UITableView.RowAnimation) {
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
    
    func bumpMe(with type: ItemBumpType, animation: UITableView.RowAnimation) {
        switch type {
        case .reload(let indexPath):
            tableView?.reloadRows(at: [indexPath], with: animation)
            
        case .reloadHeader:
            break
            
        case .reloadFooter:
            break
        }
    }
    
    func getOffscreenCell(by identifier: String) -> Cell {
        if let cell = offscreenCells[identifier] {
            return cell
        }
        
        guard let cell = tableView?.dequeueReusableCell(withIdentifier: identifier) as? Cell else { return .init() }
        
        offscreenCells[identifier] = cell
        
        return cell
    }
    
    func tableViewWidth() -> CGFloat {
        return tableView?.bounds.width ?? 0
    }
}

// MARK - UITableViewDelegate cell

extension Hakuba: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getCellmodel(at: indexPath)?.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return cellForRow(at: indexPath)?.willSelect(tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellmodel = getCellmodel(at: indexPath), let cell = cellForRow(at: indexPath) else { return }
        
        cellmodel.didSelect(cell: cell)
        cell.didSelect(tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return cellForRow(at: indexPath)?.willDeselect(tableView, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        cellForRow(at: indexPath)?.didDeselect(tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        
        cell.willDisplay(tableView)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        
        cell.didEndDisplay(tableView)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return getCellmodel(at: indexPath)?.editingStyle ?? .none
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return getCellmodel(at: indexPath)?.shouldHighlight ?? true
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        cellForRow(at: indexPath)?.didHighlight(tableView)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        cellForRow(at: indexPath)?.didUnhighlight(tableView)
    }
}

// MARK - UITableViewDelegate header-footer

extension Hakuba {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections.get(at: section)?.header?.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = sections.get(at: section)?.header,
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.reuseIdentifier) as? HeaderFooterView else {
                return nil
        }
        
        headerView.configureView(header)
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections.get(at: section)?.footer?.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sections.get(at: section)?.footer,
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.reuseIdentifier) as? HeaderFooterView else {
                return nil
        }
        
        footerView.configureView(footer)
        
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView, section == willFloatingSection else { return }
        
        view.willDisplay(tableView, section: section)
        view.didChangeFloatingState(true, section: section)
        willFloatingSection = NSNotFound
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else { return }
        
        view.willDisplay(tableView, section: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else { return }
        
        view.didEndDisplaying(tableView, section: section)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let view = view as? HeaderFooterView else { return }
        
        view.didEndDisplaying(tableView, section: section)
    }
}

// MARK - UITableViewDataSource

extension Hakuba: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.get(at: section)?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellmodel = getCellmodel(at: indexPath),
            let cell = tableView.dequeueReusableCell(withIdentifier: cellmodel.reuseIdentifier, for: indexPath) as? Cell else {
                return .init()
        }
        
        cell.configureCell(cellmodel)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        commitEditingHandler?(editingStyle, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let cellmodel = getCellmodel(at: indexPath) else { return false }
        
        return cellmodel.editable || cellEditable
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections.get(at: section)?.header?.title
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections.get(at: section)?.footer?.title
    }
}

// MARK - Private methods

private extension Hakuba {
    func setupSections(_ sections: [Section], from index: Int) {
        var index = index
        sections.forEach {
            $0.setup(at: index, delegate: self)
            index += 1
        }
    }
}
