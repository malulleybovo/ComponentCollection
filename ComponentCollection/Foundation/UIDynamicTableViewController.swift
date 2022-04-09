//
//  UIDynamicTableViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/27/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

open class UIDynamicTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public enum ReloadScheme {
        case automatic
        case manual
    }
    
    private var registeredSupplementaryViewIdentifiers: Set<String> = []
    private var registeredCellIdentifiers: Set<String> = []
    
    public var reloadScheme: ReloadScheme = .automatic
    public var sections: [CollectionSectionDescriptor] = [] {
        didSet {
            for section in sections {
                if let type = section.headerViewDescriptor?.dynamicTableViewHeaderFooterViewType,
                   !registeredSupplementaryViewIdentifiers.contains("\(type)") {
                    tableView.register(type, forHeaderFooterViewReuseIdentifier: "\(type)")
                    registeredSupplementaryViewIdentifiers.insert("\(type)")
                }
                if let type = section.footerViewDescriptor?.dynamicTableViewHeaderFooterViewType,
                   !registeredSupplementaryViewIdentifiers.contains("\(type)") {
                    tableView.register(type, forHeaderFooterViewReuseIdentifier: "\(type)")
                    registeredSupplementaryViewIdentifiers.insert("\(type)")
                }
                for item in section.items {
                    let type = item.dynamicTableViewCellType
                    if registeredCellIdentifiers.contains("\(type)") { continue }
                    tableView.register(type, forCellReuseIdentifier: "\(type)")
                    registeredCellIdentifiers.insert("\(type)")
                }
                section.onChange = { [weak self] in
                    guard let self = self else { return }
                    switch self.reloadScheme {
                    case .automatic:
                        self.tableView.reloadData()
                    case .manual:
                        break
                    }
                }
            }
            switch reloadScheme {
            case .automatic:
                tableView.reloadData()
            case .manual:
                break
            }
        }
    }
    
    public var onRefresh: ((_ completion: @escaping () -> Void) -> Void)? {
        didSet {
            setupRefreshControl()
        }
    }
    
    public var allowsMultipleSelection: Bool {
        get { tableView.allowsMultipleSelection }
        set {
            tableView.allowsMultipleSelection = newValue
            tableView.allowsMultipleSelectionDuringEditing = newValue
            switch editMode {
            case .none: break
            default:
                setEditing(newValue, animated: true)
            }
        }
    }
    
    public enum ScrollingType {
        case normal
        case infiniteWithPivotAtEnd(listener: () -> Void)
        case infinite(withPivotOffsetFromEndBy: CGFloat, listener: () -> Void)
    }
    
    public var scrollingType: ScrollingType = .normal
    private var shouldRequestMoreDataFromInfiniteScroller = true
    
    public var style: UITableView.Style { .plain }
    
    public var separatorStyle: UITableViewCell.SeparatorStyle {
        get { tableView.separatorStyle }
        set { tableView.separatorStyle = newValue }
    }
    
    public var separatorInset: UIEdgeInsets {
        get { tableView.separatorInset }
        set { tableView.separatorInset = newValue }
    }
    
    public var separatorColor: UIColor? {
        get { tableView.separatorColor }
        set { tableView.separatorColor = newValue }
    }
    
    public var separatesSectionHeaderFromRows: Bool = true
    
    public enum EditMode {
        case none
        case swipeToInsert(leading: UISwipeActionsConfiguration?, trailing: UISwipeActionsConfiguration?)
        case swipeToDelete(leading: UISwipeActionsConfiguration?, trailing: UISwipeActionsConfiguration?)
        case tapToInsert(leading: UISwipeActionsConfiguration?, trailing: UISwipeActionsConfiguration?)
        case tapToDelete(leading: UISwipeActionsConfiguration?, trailing: UISwipeActionsConfiguration?)
        case move
    }
    
    public var editMode: EditMode = .none {
        didSet {
            switch editMode {
            case .none:
                setEditing(allowsMultipleSelection, animated: true)
            case .swipeToInsert, .swipeToDelete:
                break
            case .tapToInsert, .tapToDelete, .move:
                setEditing(true, animated: true)
            }
        }
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        return tableView
    }()
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    @objc private func refresh(sender: AnyObject) {
        onRefresh?() { [weak self] in
            self?.stopRefreshing()
        }
    }
    private func setupRefreshControl() {
        refreshControl.removeFromSuperview()
        if onRefresh != nil {
            tableView.addSubview(refreshControl)
        }
    }
    private func stopRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.init(dynamicProvider: { trait in
                switch trait.userInterfaceStyle {
                case .dark:
                    return UIColor.black
                default:
                    return UIColor.white
                }
            })
        } else {
            view.backgroundColor = UIColor.white
        }
        setupTableView()
        setupRefreshControl()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    open func reloadData() {
        tableView.reloadData()
    }
    
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        multipleSelection = []
    }
    
    public func indexPath(for tableViewCell: UITableViewCell?) -> IndexPath? {
        guard let tableViewCell = tableViewCell else { return nil }
        return tableView.indexPath(for: tableViewCell)
    }
    
    public func insertRow(_ descriptor: Descriptor, at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        guard tableView === self.tableView else { return }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        sections[indexPath.section].items.insert(descriptor, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: animation)
    }
    
    public func deleteRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation = .automatic) {
        guard tableView === self.tableView else { return }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        sections[indexPath.section].items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: animation)
    }
    
    // MARK: - Delegate
    
    private(set) var multipleSelection: Set<IndexPath> = []
    public final func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView === self.tableView else { return }
        if !tableView.allowsMultipleSelection || !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        if tableView.allowsMultipleSelection, tableView.isEditing {
            guard descriptor.editable, !multipleSelection.contains(indexPath) else { return }
            multipleSelection.insert(indexPath)
        }
        descriptor.tapListener?(true)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView === self.tableView else { return }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        if tableView.allowsMultipleSelection {
            guard multipleSelection.contains(indexPath) else { return }
            multipleSelection.remove(indexPath)
        }
        descriptor.tapListener?(false)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableView === self.tableView else { return }
        for subview in cell.subviews where subview !== cell.contentView && subview.frame.origin.y < 2 {
            subview.isHidden = !separatesSectionHeaderFromRows
        }
    }
    
    // MARK: - DataSource
    
    public final func numberOfSections(in tableView: UITableView) -> Int {
        guard tableView === self.tableView else { return 0 }
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView === self.tableView else { return 0 }
        guard section >= 0, section < sections.count else { return 0 }
        guard sections[section].headerViewDescriptor != nil else { return 0 }
        return UITableView.automaticDimension
    }
    
    public final func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView === self.tableView else { return nil }
        guard section >= 0, section < sections.count else { return nil }
        guard let descriptor = sections[section].headerViewDescriptor else { return nil }
        let type = descriptor.dynamicTableViewHeaderFooterViewType
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(type)") else {
            return nil
        }
        headerView.contentView.backgroundColor = .white.withAlphaComponent(0)
        descriptor.layout(tableViewHeaderFooterView: headerView)
        return headerView
    }
    
    public final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView === self.tableView else { return 0 }
        guard section >= 0, section < sections.count else { return 0 }
        return sections[section].items.count
    }
    
    public final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView else { return UITableViewCell() }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return UITableViewCell() }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return UITableViewCell() }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        let type = descriptor.dynamicTableViewCellType
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "\(type)", for: indexPath)
        tableViewCell.separatorInset = tableView.separatorInset
        descriptor.layout(tableViewCell: tableViewCell)
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard tableView === self.tableView else { return 0 }
        guard section >= 0, section < sections.count else { return 0 }
        guard sections[section].footerViewDescriptor != nil else { return 0 }
        return UITableView.automaticDimension
    }
    
    public final func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard tableView === self.tableView else { return nil }
        guard section >= 0, section < sections.count else { return nil }
        guard let descriptor = sections[section].footerViewDescriptor else { return nil }
        let type = descriptor.dynamicTableViewHeaderFooterViewType
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(type)") else {
            return nil
        }
        descriptor.layout(tableViewHeaderFooterView: footerView)
        return footerView
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard tableView === self.tableView else { return false }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        return descriptor.editable
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch editMode {
        case .none, .move:
            return nil
        case .swipeToInsert(let leading, _):
            leading?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return leading
        case .swipeToDelete(let leading, _):
            leading?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return leading
        case .tapToInsert(let leading, _):
            leading?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return leading
        case .tapToDelete(let leading, _):
            leading?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return leading
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch editMode {
        case .none, .move:
            return nil
        case .swipeToInsert(_, let trailing):
            trailing?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return trailing
        case .swipeToDelete(_, let trailing):
            trailing?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return trailing
        case .tapToInsert(_, let trailing):
            trailing?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return trailing
        case .tapToDelete(_, let trailing):
            trailing?.actions.forEach({ ($0 as? UIContextualActionWithIndexPath)?.indexPath = indexPath })
            return trailing
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard tableView === self.tableView else { return .none }
        if tableView.allowsMultipleSelection, tableView.isEditing { return .none }
        switch editMode {
        case .none, .swipeToInsert, .swipeToDelete, .move:
            return .none
        case .tapToInsert:
            return .insert
        case .tapToDelete:
            return .delete
        }
    }
    
    /// Use in the completion handler of `UISwipeActionsConfiguration` passed to `editMode` to commit changes
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard tableView === self.tableView else { return false }
        switch editMode {
        case .none, .swipeToInsert, .swipeToDelete, .tapToInsert, .tapToDelete:
            return false
        case .move:
            break
        }
        guard tableView === self.tableView else { return false }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        return descriptor.editable
    }
    
    /// Implementation dependent
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard tableView === self.tableView else { return sourceIndexPath }
        guard sourceIndexPath.section >= 0, sourceIndexPath.section < sections.count else { return sourceIndexPath }
        guard sourceIndexPath.row >= 0, sourceIndexPath.row < sections[sourceIndexPath.section].items.count else { return sourceIndexPath }
        guard sections[sourceIndexPath.section].items[sourceIndexPath.row].editable else { return sourceIndexPath }
        guard proposedDestinationIndexPath.section >= 0, proposedDestinationIndexPath.section < sections.count else { return sourceIndexPath }
        guard proposedDestinationIndexPath.row >= 0, proposedDestinationIndexPath.row < sections[proposedDestinationIndexPath.section].items.count else { return sourceIndexPath }
        guard sections[proposedDestinationIndexPath.section].items[proposedDestinationIndexPath.row].editable else { return sourceIndexPath }
        return proposedDestinationIndexPath
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        guard tableView === self.tableView else { return false }
        return false
    }
    
    public func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        guard tableView === self.tableView else { return false }
        guard tableView.allowsMultipleSelection else { return false }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        return descriptor.editable
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.tableView else { return }
        switch scrollingType {
        case .normal:
            break
        case .infiniteWithPivotAtEnd(let listener):
            if shouldRequestMoreDataFromInfiniteScroller,
               scrollView.contentSize.height >= scrollView.frame.size.height,
               scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
                shouldRequestMoreDataFromInfiniteScroller = false
                listener()
            }
        case .infinite(let withPivotOffsetFromEndBy, let listener):
            if shouldRequestMoreDataFromInfiniteScroller,
               scrollView.contentSize.height >= scrollView.frame.size.height,
               scrollView.contentOffset.y >= max(0, scrollView.contentSize.height - scrollView.frame.height - max(0, withPivotOffsetFromEndBy)) {
                shouldRequestMoreDataFromInfiniteScroller = false
                listener()
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === self.tableView else { return }
        shouldRequestMoreDataFromInfiniteScroller = true
    }
    
}

public protocol Descriptor {
    
    var viewType: UIView.Type { get }
    var dynamicTableViewCellType: UITableViewCell.Type { get }
    var dynamicTableViewHeaderFooterViewType: UITableViewHeaderFooterView.Type { get }
    var dynamicCollectionViewCellType: UICollectionViewCell.Type { get }
    
    var tapListener: ((_ selected: Bool) -> Void)? { get set }
    var editable: Bool { get set }
    
    func layout(view: UIView)
    func layout(tableViewCell: UITableViewCell)
    func layout(tableViewHeaderFooterView: UITableViewHeaderFooterView)
    func layout(collectionViewCell: UICollectionViewCell)
    
}

open class UIViewDescriptor<V: UIView>: Descriptor, Identifiable {
    
    public let id = UUID()
    
    public var viewType: UIView.Type { V.self }
    public var dynamicTableViewCellType: UITableViewCell.Type { UIDynamicTableViewCell<V>.self }
    public var dynamicTableViewHeaderFooterViewType: UITableViewHeaderFooterView.Type { UIDynamicTableViewHeaderFooterView<V>.self }
    public var dynamicCollectionViewCellType: UICollectionViewCell.Type { UIDynamicCollectionViewCell<V>.self }
    
    public var tapListener: ((_ selected: Bool) -> Void)?
    @discardableResult
    public final func tapListener(_ tapListener: ((_ selected: Bool) -> Void)?) -> UIViewDescriptor<V> {
        self.tapListener = tapListener
        return self
    }
    
    public var editable: Bool = false
    @discardableResult
    public final func editable(_ editable: Bool) -> UIViewDescriptor<V> {
        self.editable = editable
        return self
    }
    
    public var separated: Bool = true
    @discardableResult
    public final func separated(_ separated: Bool) -> UIViewDescriptor<V> {
        self.separated = separated
        return self
    }
    
    public var separatorInset: UIEdgeInsets?
    @discardableResult
    public final func separatorInset(_ separatorInset: UIEdgeInsets?) -> UIViewDescriptor<V> {
        self.separatorInset = separatorInset
        return self
    }
    
    public var contentInset: UIEdgeInsets?
    @discardableResult
    public final func contentInset(_ contentInset: UIEdgeInsets?) -> UIViewDescriptor<V> {
        self.contentInset = contentInset
        return self
    }
    
    public var backgroundColor: UIColor?
    @discardableResult
    public final func backgroundColor(_ backgroundColor: UIColor?) -> UIViewDescriptor<V> {
        self.backgroundColor = backgroundColor
        return self
    }
    
    /// Implementation dependent. Override to define the view layout.
    open func layout(view: V) { }
    
    public final func layout(view: UIView) {
        guard let view = view as? V else { return }
        view.backgroundColor = backgroundColor
        layout(view: view)
    }
    
    public final func layout(tableViewCell: UITableViewCell) {
        guard let tableViewCell = tableViewCell as? UIDynamicTableViewCell<V> else { return }
        if !separated {
            tableViewCell.separatorInset = UIEdgeInsets(top: 0, left: 100000, bottom: 0, right: 0)
        } else if let separatorInset = separatorInset {
            tableViewCell.separatorInset = separatorInset
        }
        tableViewCell.backgroundColor = backgroundColor
        tableViewCell.contentInset = contentInset
        layout(view: tableViewCell.view)
    }
    
    public final func layout(tableViewHeaderFooterView: UITableViewHeaderFooterView) {
        guard let tableViewHeaderFooterView = tableViewHeaderFooterView as? UIDynamicTableViewHeaderFooterView<V> else { return }
        tableViewHeaderFooterView.backgroundColor = backgroundColor
        layout(view: tableViewHeaderFooterView.view)
    }
    
    public func layout(collectionViewCell: UICollectionViewCell) {
        guard let collectionViewCell = collectionViewCell as? UIDynamicCollectionViewCell<V> else { return }
        collectionViewCell.contentInset = contentInset
        collectionViewCell.backgroundColor = backgroundColor
        layout(view: collectionViewCell.view)
    }
    
}

public class CollectionSectionDescriptor {
    public var headerViewDescriptor: Descriptor? { didSet { onChange?() } }
    public var footerViewDescriptor: Descriptor? { didSet { onChange?() } }
    public var items: [Descriptor] { didSet { onChange?() } }
    public var onChange: (() -> Void)?
    public init(header: Descriptor? = nil, items: Descriptor..., footer: Descriptor? = nil) {
        self.headerViewDescriptor = header
        self.footerViewDescriptor = footer
        self.items = items
    }
    public init(header: Descriptor? = nil, items: [Descriptor], footer: Descriptor? = nil) {
        self.headerViewDescriptor = header
        self.footerViewDescriptor = footer
        self.items = items
    }
}

public class UIDynamicTableViewHeaderFooterView<V: UIView>: UITableViewHeaderFooterView {
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        setupView()
    }
    
    private(set) lazy var view: V = {
        let v = V()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private func setupView() {
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}

public class UIDynamicTableViewCell<V: UIView>: UITableViewCell {
    
    public var contentInset: UIEdgeInsets? {
        didSet {
            guard contentInset != oldValue else { return }
            setupUI()
        }
    }
    
    public var selectionStyles: (normal: SelectionStyle, edit: SelectionStyle) = (normal: .none, edit: .default)
    
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        selectionStyle = editing ? selectionStyles.edit : selectionStyles.normal
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        setupView()
    }
    
    private(set) lazy var view: V = {
        let v = V()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private func setupView() {
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentInset?.top ?? 0),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentInset?.left ?? 0),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(contentInset?.bottom ?? 0)),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(contentInset?.right ?? 0))
        ])
    }
    
}

public class UIContextualActionWithIndexPath: UIContextualAction {
    
    fileprivate var indexPath: IndexPath?
    fileprivate var customHandler: Handler = { _, _, _ in }
    public override var handler: Handler { customHandler }
    
    public convenience init(style: Style, title: String?, image: UIImage? = nil, backgroundColor: UIColor? = nil, customHandler: @escaping (UIContextualAction, UIView, IndexPath?, (Bool) -> Void) -> Void) {
        self.init(style: style, title: title, handler: { _, _, _ in })
        self.customHandler = { [weak self] action, view, completion in
            customHandler(action, view, self?.indexPath, completion)
        }
        self.backgroundColor = backgroundColor
        self.image = image
    }
    
}
