//
//  SampleDynamicCollectionViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/28/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class SampleDynamicCollectionViewController: UIDynamicCollectionViewController {
    
    private var isRequestingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globalCellSelectionStyle = .normal
        allowsMultipleSelection = true
        scrollingType = .infinite(withPivotOffsetFromEndBy: 200, listener: { [weak self] in
            guard let self = self, !self.isRequestingMoreData else { return }
            self.isRequestingMoreData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.isRequestingMoreData = false
                self?.sections.last?.items.append(contentsOf: [
                    UILabelDescriptor(text: "infinite scrolling dynamic content A"),
                    UILabelDescriptor(text: "infinite scrolling dynamic content B"),
                    UILabelDescriptor(text: "infinite scrolling dynamic content C"),
                    UILabelDescriptor(text: "infinite scrolling dynamic content D"),
                    UILabelDescriptor(text: "infinite scrolling dynamic content E")
                ])
            }
        })
        sections = {
            var sections: [CollectionSectionDescriptor] = []
            for sectionIndex in 0..<10 {
                sections.append(CollectionSectionDescriptor(
                    header: UILabelDescriptor(
                        text: sectionIndex % 2 == 0 ?
                            "HEADER WITH CONTENT INSET \(sectionIndex)" :
                            "HUGE HEADER TEXT THAT WILL REQUIRE LINE BREAKS TO TEST DYNAMIC SIZING TO FIT WITH CONTENT INSET \(sectionIndex)")
                        .contentInset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                        .backgroundColor(UIColor(
                            red: CGFloat.random(in: 0.6...1),
                            green: CGFloat.random(in: 0.6...1),
                            blue: CGFloat.random(in: 0.6...1),
                            alpha: 1)),
                    items: {
                        var items: [Descriptor] = []
                        for index in 0..<10 {
                            items.append(UILabelDescriptor(
                                text: "row \(index)")
                                .backgroundColor(UIColor(
                                    red: CGFloat.random(in: 0.6...1),
                                    green: CGFloat.random(in: 0.6...1),
                                    blue: CGFloat.random(in: 0.6...1),
                                    alpha: 1))
                                .editable(sectionIndex <= 1)
                                .tapListener({ selected in
                                    print(selected ? "selected row \(index)" : "deselected row \(index)")
                                }))
                        }
                        return items
                    }(),
                    footer: UILabelDescriptor(
                        text: sectionIndex % 2 != 0 ?
                            "FOOTER WITH CONTENT INSET \(sectionIndex)" :
                            "HUGE FOOTER TEXT THAT WILL REQUIRE LINE BREAKS TO TEST DYNAMIC SIZING TO FIT WITH CONTENT INSET \(sectionIndex)")
                        .contentInset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
                        .backgroundColor(UIColor(
                            red: CGFloat.random(in: 0.6...1),
                            green: CGFloat.random(in: 0.6...1),
                            blue: CGFloat.random(in: 0.6...1),
                            alpha: 1))))
            }
            return sections
        }()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.section >= 0, indexPath.section < sections.count else { return CGSize.zero }
        guard indexPath.row >= 0, indexPath.row < sections[indexPath.section].items.count else { return CGSize.zero }
        let descriptor = sections[indexPath.section].items[indexPath.row]
        let cell = descriptor.dynamicCollectionViewCellType.init(frame: CGRect.zero)
        descriptor.layout(collectionViewCell: cell)
        if indexPath.section % 2 == 0 {
            let rowSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
            let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            let itemsPerRow: CGFloat = 4
            return cell.systemLayoutSizeFitting(
                CGSize(width: floor((collectionView.bounds.width - inset.left - inset.right) / itemsPerRow - rowSpacing * (itemsPerRow - 1) / itemsPerRow),
                       height: UIView.layoutFittingExpandedSize.height),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        } else {
            let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
            return cell.systemLayoutSizeFitting(CGSize(width: collectionView.bounds.width - inset.left - inset.right, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        }
    }
    
}
