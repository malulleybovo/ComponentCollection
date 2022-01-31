//
//  DiscordChatView.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class DiscordChatView: BaseViewController {
    
    private lazy var mainView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 6
        return v
    }()
    
    private lazy var mockup1View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .darkGray
        return v
    }()
    
    private lazy var mockup2View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .darkGray
        return v
    }()
    
    private lazy var mockup3View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .darkGray
        return v
    }()
    
    private lazy var mockup4View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .darkGray
        return v
    }()
    
    override func setupUI() {
        super.setupUI()
        view.backgroundColor = .gray
        view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 6),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        mainView.addSubview(mockup1View)
        NSLayoutConstraint.activate([
            mockup1View.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            mockup1View.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            mockup1View.heightAnchor.constraint(equalToConstant: 20),
            mockup1View.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20)
        ])
        mainView.addSubview(mockup2View)
        NSLayoutConstraint.activate([
            mockup2View.topAnchor.constraint(equalTo: mockup1View.bottomAnchor, constant: 20),
            mockup2View.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            mockup2View.heightAnchor.constraint(equalToConstant: 20),
            mockup2View.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20)
        ])
        mainView.addSubview(mockup3View)
        NSLayoutConstraint.activate([
            mockup3View.topAnchor.constraint(equalTo: mockup2View.bottomAnchor, constant: 20),
            mockup3View.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            mockup3View.heightAnchor.constraint(equalToConstant: 20),
            mockup3View.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.5)
        ])
        mainView.addSubview(mockup4View)
        NSLayoutConstraint.activate([
            mockup4View.topAnchor.constraint(equalTo: mockup3View.bottomAnchor, constant: 20),
            mockup4View.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            mockup4View.heightAnchor.constraint(equalToConstant: 20),
            mockup4View.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.25)
        ])
    }
    
}
