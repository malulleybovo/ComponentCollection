//
//  SampleDynamicTableViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/28/22.
//

import UIKit

class SampleDynamicTableViewController: UIDynamicTableViewController {
    
    private var isRequestingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editMode = .swipeToDelete(leading: UISwipeActionsConfiguration(actions: [
            UIContextualActionWithIndexPath(
                style: .normal,
                title: "read",
                backgroundColor: UIColor.systemYellow,
                customHandler: { action, view, indexPath, completion in
                    guard let indexPath = indexPath else { return }
                    print(indexPath)
                    completion(true)
                })
        ]), trailing: UISwipeActionsConfiguration(actions: [
            UIContextualActionWithIndexPath(
                style: .normal,
                title: "delete",
                backgroundColor: UIColor.systemRed,
                customHandler: { action, view, indexPath, completion in
                    guard let indexPath = indexPath else { return }
                    print(indexPath)
                    completion(true)
                })
        ]))
        scrollingType = .infinite(withPivotOffsetFromEndBy: 200, listener: { [weak self] in
            guard let self = self, !self.isRequestingMoreData else { return }
            self.isRequestingMoreData = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.isRequestingMoreData = false
                self?.sections.last?.items.append(contentsOf: [
                    UILabelDescriptor(text: "infinite scrolling dynamic content A").editable(true),
                    UILabelDescriptor(text: "infinite scrolling dynamic content B").editable(true),
                    UILabelDescriptor(text: "infinite scrolling dynamic content C").editable(true),
                    UILabelDescriptor(text: "infinite scrolling dynamic content D").editable(true),
                    UILabelDescriptor(text: "infinite scrolling dynamic content E").editable(true)
                ])
            }
        })
        sections = {
            var sections: [CollectionSectionDescriptor] = []
            for index in 0..<10 {
                sections.append(CollectionSectionDescriptor(
                    header: UILabelDescriptor(text: "HEADER \(index)"),
                    items: {
                        var items: [Descriptor] = []
                        for index in 0..<10 {
                            items.append(UILabelDescriptor(
                                text: "row \(index)")
                                .tapListener({ selected in
                                    print("item 2 selected \(selected)")
                                })
                                .separated(true)
                                .editable(true)
                                .tapListener({ selected in
                                    print(selected ? "selected row" : "deselected row")
                                }))
                        }
                        return items
                    }(),
                    footer: UILabelDescriptor(text: "FOOTER \(index)")))
            }
            return sections
        }()
    }
    
}
