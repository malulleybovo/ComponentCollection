//
//  BaseTableViewController.swift
//  SwiftProjectX
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

protocol BaseTableViewDelegate: UITableViewDelegate {
    associatedtype C: UITableViewCell
    associatedtype M
    
    func refreshRequested()
    func dequeued(cell: C, item: M, at indexPath: IndexPath)
    func selected(item: M, at indexPath: IndexPath)
}

class BaseTableViewController<M, C: UITableViewCell>: BaseViewController, BaseTableViewDelegate, UITableViewDataSource {
    
    var separatorStyle: UITableViewCell.SeparatorStyle {
        .singleLine
    }
    
    private let cellReuseId = "cell"
    
    private(set) var dataList: [M] = []
    
    func set(dataList: [M]) {
        self.dataList = dataList
        tableView.reloadData()
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = separatorStyle
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = CGFloat(40.0)
        tableView.register(C.self, forCellReuseIdentifier: cellReuseId)
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
        refreshRequested()
    }
    private func setupRefreshControl() {
        tableView.addSubview(refreshControl)
    }
    func stopRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
    }
    
    // MARK: - Delegate
    
    func refreshRequested() { }
    
    func dequeued(cell: C, item: M, at indexPath: IndexPath) { }
    
    func selected(item: M, at indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        guard row >= 0, row <= dataList.count else {
            return
        }
        let rowData = dataList[row]
        selected(item: rowData, at: indexPath)
    }
    
    // MARK: - DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        guard row >= 0, row <= dataList.count else {
            return reusableCell
        }
        let rowData = dataList[row]
        if let reusableCell = reusableCell as? C {
            dequeued(cell: reusableCell, item: rowData, at: indexPath)
        }
        return reusableCell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        let insets = tableView.separatorInset
        let width = tableView.bounds.width - insets.left - insets.right
        let separatorLayer = CALayer()
        separatorLayer.frame = CGRect(x: insets.left, y: -0.5, width: width, height: 0.5)
        separatorLayer.backgroundColor = tableView.separatorColor?.cgColor
        footer.layer.addSublayer(separatorLayer)
        return footer
    }
    
}
