//
//  LandingView.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class LandingView: BaseTableViewController<LandingItemCellModel, LandingItemCell> {
    
    override func refreshRequested() {
        super.refreshRequested()
        stopRefreshing()
    }
    
    override func dequeued(cell: LandingItemCell, item: LandingItemCellModel, at indexPath: IndexPath) {
        super.dequeued(cell: cell, item: item, at: indexPath)
        cell.label.text = item.text
    }
    
    override func selected(item: LandingItemCellModel, at indexPath: IndexPath) {
        super.selected(item: item, at: indexPath)
        item.onTap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(dataList: [
            LandingItemCellModel(text: "Discord Menu Controller", onTap: {
                UIApplication.shared.appDelegate?.setWindowToDiscordMenu()
            }),
            LandingItemCellModel(text: "Dynamic UITableViewController", onTap: {
                UIApplication.shared.appDelegate?.setWindow(to: SampleDynamicTableViewController.self)
            }),
            LandingItemCellModel(text: "Dynamic UICollectionViewController", onTap: {
                UIApplication.shared.appDelegate?.setWindow(to: SampleDynamicCollectionViewController.self)
            }),
            LandingItemCellModel(text: "ApiRequestSampleViewController", onTap: {
                UIApplication.shared.appDelegate?.setWindow(to: ApiRequestSampleViewController.self)
            }),
            LandingItemCellModel(text: "UUIDScannerViewController", onTap: {
                if #available(iOS 13.0, *) {
                    UIApplication.shared.appDelegate?.setWindow(to: UUIDScannerViewController.self)
                } else {
                    let alert = UIAlertController(title: "Feature only available on iOS 13.0 and above.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
            }),
            LandingItemCellModel(text: "UITappableLinkViewController", onTap: {
                UIApplication.shared.appDelegate?.setWindow(to: UITappableLabelViewController.self)
            }),
        ])
    }
    
}

