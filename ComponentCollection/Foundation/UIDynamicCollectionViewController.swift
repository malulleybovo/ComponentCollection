//
//  UIDynamicCollectionViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/28/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

public class UIDynamicCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public var layout: UICollectionViewLayout { UICollectionViewFlowLayout() }
    
    public enum ReloadScheme {
        case automatic
        case manual
    }
    
    private var registeredHeaderViewIdentifiers: Set<String> = []
    private var registeredFooterViewIdentifiers: Set<String> = []
    private var registeredCellIdentifiers: Set<String> = []
    
    public var reloadScheme: ReloadScheme = .automatic
    public var sections: [CollectionSectionDescriptor] = [] {
        didSet {
            for section in sections {
                if let type = section.headerViewDescriptor?.dynamicCollectionViewCellType,
                   !registeredHeaderViewIdentifiers.contains("\(type)") {
                    collectionView.register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(type)")
                    registeredHeaderViewIdentifiers.insert("\(type)")
                }
                if let type = section.footerViewDescriptor?.dynamicCollectionViewCellType,
                   !registeredFooterViewIdentifiers.contains("\(type)") {
                    collectionView.register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "\(type)")
                    registeredFooterViewIdentifiers.insert("\(type)")
                }
                for item in section.items {
                    let type = item.dynamicCollectionViewCellType
                    if registeredCellIdentifiers.contains("\(type)") { continue }
                    collectionView.register(type, forCellWithReuseIdentifier: "\(type)")
                    registeredCellIdentifiers.insert("\(type)")
                }
                section.onChange = { [weak self] in
                    guard let self = self else { return }
                    switch self.reloadScheme {
                    case .automatic:
                        self.collectionView.reloadData()
                    case .manual:
                        break
                    }
                }
            }
            switch reloadScheme {
            case .automatic:
                collectionView.reloadData()
            case .manual:
                break
            }
        }
    }
    
    public var allowsMultipleSelection: Bool {
        get { collectionView.allowsMultipleSelection }
        set {
            collectionView.allowsMultipleSelection = newValue
        }
    }
    
    public enum ScrollingType {
        case normal
        case infiniteWithPivotAtEnd(listener: () -> Void)
        case infinite(withPivotOffsetFromEndBy: CGFloat, listener: () -> Void)
    }
    
    public var scrollingType: ScrollingType = .normal
    private var shouldRequestMoreDataFromInfiniteScroller = true
    
    public var globalCellSelectionStyle: UICollectionViewCellSelectionStyle?
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
        setupCollectionView()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public final func section(at indexPath: IndexPath) -> CollectionSectionDescriptor? {
        guard indexPath.section >= 0, indexPath.section < sections.count else { return nil }
        return sections[indexPath.section]
    }
    
    public final func item<T: Descriptor>(at indexPath: IndexPath, as: T.Type) -> T? {
        guard indexPath.section >= 0, indexPath.section < sections.count else { return nil }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return nil }
        let descriptor = sections[indexPath.section].items[indexPath.row] as? T
        return descriptor
    }
    
    // MARK: Delegate
    
    private(set) var multipleSelection: Set<IndexPath> = []
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView === self.collectionView else { return }
        if !isEditing {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        if isEditing {
            guard descriptor.editable else {
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }
            if collectionView.allowsMultipleSelection {
                guard !multipleSelection.contains(indexPath) else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                    return
                }
                multipleSelection.insert(indexPath)
            }
        }
        descriptor.tapListener?(true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView === self.collectionView else { return true }
        if isEditing {
            guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
            guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
            let descriptor = sections[indexPath.section].items[indexPath.row]
            return descriptor.editable
        } else {
            return true
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard collectionView === self.collectionView else { return }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        if collectionView.allowsMultipleSelection {
            guard multipleSelection.contains(indexPath) else { return }
            multipleSelection.remove(indexPath)
        }
        descriptor.tapListener?(false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        guard collectionView === self.collectionView else { return false }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        return descriptor.editable
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        guard collectionView === self.collectionView else { return false }
        guard collectionView.allowsMultipleSelection else { return false }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return false }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return false }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        return descriptor.editable
    }
    
    public func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        setEditing(true, animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.collectionView else { return }
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
        guard scrollView === self.collectionView else { return }
        shouldRequestMoreDataFromInfiniteScroller = true
    }
    
    // MARK: Layout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard collectionView === self.collectionView else { return CGSize() }
        guard section >= 0, section < sections.count else { return CGSize() }
        guard let descriptor = sections[section].headerViewDescriptor else { return CGSize() }
        let cell = descriptor.dynamicCollectionViewCellType.init(frame: CGRect.zero)
        descriptor.layout(collectionViewCell: cell)
        return cell.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard collectionView === self.collectionView else { return CGSize.zero }
        guard section >= 0, section < sections.count else { return CGSize.zero }
        guard let descriptor = sections[section].footerViewDescriptor else { return CGSize.zero }
        let cell = descriptor.dynamicCollectionViewCellType.init(frame: CGRect.zero)
        descriptor.layout(collectionViewCell: cell)
        return cell.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView === self.collectionView else { return CGSize.zero }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return CGSize.zero }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return CGSize.zero }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        let cell = descriptor.dynamicCollectionViewCellType.init(frame: CGRect.zero)
        descriptor.layout(collectionViewCell: cell)
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        return cell.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width - inset.left - inset.right, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    // MARK - Datasource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard collectionView === self.collectionView else { return 0 }
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard collectionView === self.collectionView else { return UICollectionReusableView() }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return UICollectionReusableView() }
        let descriptor: Descriptor
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = sections[indexPath.section].headerViewDescriptor else { return UICollectionReusableView() }
            descriptor = header
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = sections[indexPath.section].footerViewDescriptor else { return UICollectionReusableView() }
            descriptor = footer
        } else { return UICollectionReusableView() }
        let type = descriptor.dynamicCollectionViewCellType
        guard let collectionViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(type)", for: indexPath) as? UICollectionViewCell else {
            return UICollectionReusableView()
        }
        collectionViewCell.backgroundColor = UIColor.white.withAlphaComponent(0)
        descriptor.layout(collectionViewCell: collectionViewCell)
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView === self.collectionView else { return 0 }
        guard section >= 0, section < sections.count else { return 0 }
        return sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard collectionView === self.collectionView else { return UICollectionViewCell() }
        guard indexPath.section >= 0, indexPath.section < sections.count else { return UICollectionViewCell() }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return UICollectionViewCell() }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        let type = descriptor.dynamicCollectionViewCellType
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath)
        descriptor.layout(collectionViewCell: collectionViewCell)
        if var cell = collectionViewCell as? UICollectionViewCellStyle {
            cell.selectionStyle = globalCellSelectionStyle ?? .normal
        }
        return collectionViewCell
    }
    
}

public enum UICollectionViewCellSelectionStyle {
    case normal
    case unset
}

protocol UICollectionViewCellStyle {
    
    var selectionStyle: UICollectionViewCellSelectionStyle { get set }
    
}

public class UIDynamicCollectionViewCell<V: UIView>: UICollectionViewCell, UICollectionViewCellStyle {
    
    public var selectionStyle: UICollectionViewCellSelectionStyle = .normal
    
    public override var isSelected: Bool {
        didSet {
            switch selectionStyle {
            case .normal:
                alpha = isSelected ? 0.6 : 1
            case .unset: break
            }
        }
    }
    
    public var contentInset: UIEdgeInsets? {
        didSet {
            guard contentInset != oldValue else { return }
            setupUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
