//
//  UINavigationButton.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class UINavigationButton: UIView {
    
    static let shared = UINavigationButton()
    
    private var ready: Bool { superview != nil }
    private let size = CGSize(width: 60, height: 60)
    
    private var timer: Timer?
    
    final func attemptToLaunch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.launch()
            if !self.ready {
                self.attemptToLaunch()
            }
        }
    }
    
    private func launch() {
        guard superview == nil else { return }
        guard let superview = UIApplication.shared.keyWindow else { return }
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 0.5 * min(size.width, size.height)
        layer.masksToBounds = false
        layer.borderWidth = 5
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.text = "\u{27F2}"
        label.textAlignment = .center
        addSubview(label)
        superview.addSubview(self)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -40),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -40),
            label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -2.5),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -5)
        ])
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.init(dynamicProvider: { trait in
                switch trait.userInterfaceStyle {
                case .dark:
                    return UIColor.black
                default:
                    return UIColor.white
                }
            }).withAlphaComponent(0.8)
            layer.borderColor = UIColor.red.withAlphaComponent(0.8).cgColor
            label.textColor = UIColor.red
        } else {
            backgroundColor = UIColor.white.withAlphaComponent(0.8)
            layer.borderColor = UIColor.red.withAlphaComponent(0.8).cgColor
            label.textColor = UIColor.red
        }
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.superview?.bringSubviewToFront(self)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview, let gestureView = gesture.view else { return }
        let translation = gesture.translation(in: superview)
        gestureView.center = CGPoint(
            x: gestureView.center.x + translation.x,
            y: gestureView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: superview)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        UIApplication.shared.appDelegate?.setWindowToEntryPoint()
    }
    
}
