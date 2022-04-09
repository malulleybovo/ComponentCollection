//
//  BaseViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func open(_ viewController: BaseViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        setupUI()
    }
    
    func setupUI() { }
    
    func alert(message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
}
