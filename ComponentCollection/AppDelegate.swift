//
//  AppDelegate.swift
//  ComponentCollection
//
//  Created by malulleybovo on 30/01/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        setWindowToEntryPoint()
        window?.makeKeyAndVisible()
        return true
    }
    
}

extension AppDelegate {
    
    func setWindowToEntryPoint() {
        window?.rootViewController = LandingView()
    }
    
    func setWindowToDiscordMenu() {
        let menu = DiscordMenuController()
        menu.view.backgroundColor = .darkGray
        menu.leftMenuController = DiscordLeftMenuView()
        menu.mainController = DiscordChatView()
        menu.rightMenuController = DiscordRightMenuView()
        window?.rootViewController = menu
    }
    
}

extension UIApplication {
    
    var appDelegate: AppDelegate? { delegate as? AppDelegate }
    
}
