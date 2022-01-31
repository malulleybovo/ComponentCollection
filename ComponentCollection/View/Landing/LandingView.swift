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
            })
        ])
    }
    
}

