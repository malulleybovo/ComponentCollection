//
//  DiscordLeftMenuView.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class DiscordLeftMenuView: BaseViewController {
    
    private lazy var serversView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 6
        return v
    }()
    
    private lazy var mockupServer1View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray.withAlphaComponent(0.8)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()
    
    private lazy var mockupServer2View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray.withAlphaComponent(0.8)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 25
        return v
    }()
    
    private lazy var mockupServer3View: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray.withAlphaComponent(0.8)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 25
        return v
    }()
    
    private lazy var chatsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray.withAlphaComponent(0.8)
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
        view.backgroundColor = .clear
        view.addSubview(serversView)
        NSLayoutConstraint.activate([
            serversView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            serversView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            serversView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        serversView.addSubview(mockupServer1View)
        NSLayoutConstraint.activate([
            mockupServer1View.topAnchor.constraint(equalTo: serversView.topAnchor, constant: 10),
            mockupServer1View.leadingAnchor.constraint(equalTo: serversView.leadingAnchor, constant: 15),
            mockupServer1View.widthAnchor.constraint(equalToConstant: 50),
            mockupServer1View.heightAnchor.constraint(equalToConstant: 50),
            mockupServer1View.trailingAnchor.constraint(equalTo: serversView.trailingAnchor, constant: -5)
        ])
        serversView.addSubview(mockupServer2View)
        NSLayoutConstraint.activate([
            mockupServer2View.topAnchor.constraint(equalTo: mockupServer1View.bottomAnchor, constant: 20),
            mockupServer2View.leadingAnchor.constraint(equalTo: serversView.leadingAnchor, constant: 15),
            mockupServer2View.widthAnchor.constraint(equalToConstant: 50),
            mockupServer2View.heightAnchor.constraint(equalToConstant: 50),
            mockupServer2View.trailingAnchor.constraint(equalTo: serversView.trailingAnchor, constant: -5)
        ])
        serversView.addSubview(mockupServer3View)
        NSLayoutConstraint.activate([
            mockupServer3View.topAnchor.constraint(equalTo: mockupServer2View.bottomAnchor, constant: 20),
            mockupServer3View.leadingAnchor.constraint(equalTo: serversView.leadingAnchor, constant: 15),
            mockupServer3View.widthAnchor.constraint(equalToConstant: 50),
            mockupServer3View.heightAnchor.constraint(equalToConstant: 50),
            mockupServer3View.trailingAnchor.constraint(equalTo: serversView.trailingAnchor, constant: -5)
        ])
        view.addSubview(chatsView)
        NSLayoutConstraint.activate([
            chatsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatsView.leadingAnchor.constraint(equalTo: serversView.trailingAnchor, constant: 8),
            chatsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 6),
            chatsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        chatsView.addSubview(mockup1View)
        NSLayoutConstraint.activate([
            mockup1View.topAnchor.constraint(equalTo: chatsView.topAnchor, constant: 20),
            mockup1View.leadingAnchor.constraint(equalTo: chatsView.leadingAnchor, constant: 20),
            mockup1View.heightAnchor.constraint(equalToConstant: 20),
            mockup1View.trailingAnchor.constraint(equalTo: chatsView.trailingAnchor, constant: -20)
        ])
        chatsView.addSubview(mockup2View)
        NSLayoutConstraint.activate([
            mockup2View.topAnchor.constraint(equalTo: mockup1View.bottomAnchor, constant: 20),
            mockup2View.leadingAnchor.constraint(equalTo: chatsView.leadingAnchor, constant: 20),
            mockup2View.heightAnchor.constraint(equalToConstant: 20),
            mockup2View.trailingAnchor.constraint(equalTo: chatsView.trailingAnchor, constant: -20)
        ])
        chatsView.addSubview(mockup3View)
        NSLayoutConstraint.activate([
            mockup3View.topAnchor.constraint(equalTo: mockup2View.bottomAnchor, constant: 20),
            mockup3View.leadingAnchor.constraint(equalTo: chatsView.leadingAnchor, constant: 20),
            mockup3View.heightAnchor.constraint(equalToConstant: 20),
            mockup3View.widthAnchor.constraint(equalTo: chatsView.widthAnchor, multiplier: 0.5)
        ])
        chatsView.addSubview(mockup4View)
        NSLayoutConstraint.activate([
            mockup4View.topAnchor.constraint(equalTo: mockup3View.bottomAnchor, constant: 20),
            mockup4View.leadingAnchor.constraint(equalTo: chatsView.leadingAnchor, constant: 20),
            mockup4View.heightAnchor.constraint(equalToConstant: 20),
            mockup4View.widthAnchor.constraint(equalTo: chatsView.widthAnchor, multiplier: 0.25)
        ])
    }
    
}
