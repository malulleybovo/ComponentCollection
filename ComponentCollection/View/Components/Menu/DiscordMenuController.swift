//
//  DiscordMenuController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class DiscordMenuController: BaseViewController {
    
    var leftMenuController: UIViewController? {
        didSet {
            guard leftMenuController != oldValue else { return }
            setup()
        }
    }
    var mainController: UIViewController? {
        didSet {
            guard mainController != oldValue else { return }
            setup()
        }
    }
    var rightMenuController: UIViewController? {
        didSet {
            guard leftMenuController != oldValue else { return }
            setup()
        }
    }
    
    private let menuOffsetX: CGFloat = 30
    private var initialPanLocation: CGPoint = .zero
    private var initialMainLocation: CGPoint = .zero
    private var cachedMainViewBackgroundColor: UIColor?
    private var animating = false
    private var panning = false
    
    private func setup() {
        guard let leftMenuController = leftMenuController,
              let mainController = mainController else {
            leftMenuController?.view.removeFromSuperview()
            mainController?.view.removeFromSuperview()
            return
        }
        addChild(leftMenuController)
        addChild(mainController)
        view.addSubview(mainController.view)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
    }
    
    private func loadLeftMenu() {
        guard let leftMenuController = leftMenuController,
              leftMenuController.view.superview !== view else {
            return
        }
        view.addSubview(leftMenuController.view)
        view.sendSubviewToBack(leftMenuController.view)
        leftMenuController.view.frame = CGRect(
            origin: leftMenuController.view.frame.origin,
            size: CGSize(
                width: view.frame.width - menuOffsetX,
                height: view.frame.height))
        leftMenuController.view.center.x = self.view.center.x - 0.5 * menuOffsetX
    }
    
    private func unloadLeftMenu() {
        guard let leftMenuController = leftMenuController,
              leftMenuController.view.superview === view else {
            return
        }
        leftMenuController.view.removeFromSuperview()
    }
    
    private func loadRightMenu() {
        guard let rightMenuController = rightMenuController,
              rightMenuController.view.superview !== view else {
            return
        }
        view.addSubview(rightMenuController.view)
        view.sendSubviewToBack(rightMenuController.view)
        rightMenuController.view.frame = CGRect(
            origin: rightMenuController.view.frame.origin,
            size: CGSize(
                width: view.frame.width - menuOffsetX,
                height: view.frame.height))
        rightMenuController.view.center.x = self.view.center.x + 0.5 * menuOffsetX
    }
    
    private func unloadRightMenu() {
        guard let rightMenuController = rightMenuController,
              rightMenuController.view.superview === view else {
            return
        }
        rightMenuController.view.removeFromSuperview()
    }
    
    @objc private func didPan(_ sender: UIPanGestureRecognizer) {
        guard sender.state == .began || panning else { return }
        guard let leftMenuController = leftMenuController,
              let mainController = mainController,
              let rightMenuController = rightMenuController,
              !animating else {
            return
        }
        switch sender.state {
        case .began:
            panning = true
            initialMainLocation = mainController.view.center
            initialPanLocation = sender.translation(in: view)
            if cachedMainViewBackgroundColor != nil {
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                    mainController.view.backgroundColor = self.cachedMainViewBackgroundColor
                    mainController.view.subviews.forEach({ $0.alpha = 1 })
                }
            }
        case .changed:
            let translation = sender.translation(in: view)
            let displacementX = translation.x - initialPanLocation.x
            let updatedMainCenter = initialMainLocation.x + displacementX
            mainController.view.center.x = min(
                view.center.x + leftMenuController.view.frame.width,
                max(updatedMainCenter, view.center.x - rightMenuController.view.frame.width))
            if mainController.view.center.x >= view.center.x {
                loadLeftMenu()
                unloadRightMenu()
            } else {
                unloadLeftMenu()
                loadRightMenu()
            }
        case .ended,
             .cancelled:
            panning = false
            animating = true
            if mainController.view.center.x >= view.center.x {
                let factor: CGFloat = initialMainLocation.x <= view.center.x ? 0.2 : 0.8
                if mainController.view.center.x - view.center.x <= factor * view.frame.width {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        mainController.view.center.x = self.view.center.x
                    } completion: { _ in
                        self.animating = false
                        self.unloadLeftMenu()
                    }
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        mainController.view.center.x = self.view.center.x + leftMenuController.view.frame.width
                    } completion: { _ in
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                            self.cachedMainViewBackgroundColor = mainController.view.backgroundColor
                            mainController.view.backgroundColor = .clear
                            mainController.view.subviews.forEach({ $0.alpha = 0.25 })
                        } completion: { _ in
                            self.animating = false
                        }
                    }
                }
            } else {
                let factor: CGFloat = initialMainLocation.x >= view.center.x ? 0.2 : 0.8
                if mainController.view.center.x - view.center.x >= -factor * view.frame.width {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        mainController.view.center.x = self.view.center.x
                    } completion: { _ in
                        self.animating = false
                        self.unloadRightMenu()
                    }
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                        mainController.view.center.x = self.view.center.x - rightMenuController.view.frame.width
                    } completion: { _ in
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                            self.cachedMainViewBackgroundColor = mainController.view.backgroundColor
                            mainController.view.backgroundColor = .clear
                            mainController.view.subviews.forEach({ $0.alpha = 0.25 })
                        } completion: { _ in
                            self.animating = false
                        }
                    }
                }
            }
        default:
            break
        }
    }
    
}
