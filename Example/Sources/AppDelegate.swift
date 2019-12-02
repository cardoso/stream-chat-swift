//
//  AppDelegate.swift
//  StreamChat
//
//  Created by Alexey Bukhtin on 29/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import StreamChat
import StreamChatCore
import RxSwift
import RxCocoa

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DateFormatter.log = nil
        Client.config = .init(apiKey: "qk4nn7rpcn75", logOptions: .debug)
        
        setupNotifications()
        return true
    }
    
    private func setupNotifications() {
        Notifications.shared.clearApplicationIconBadgeNumberOnAppActive = true
        
        Notifications.shared.showNewMessage = { [weak self] messageReference in
            if let tabBarController = self?.window?.rootViewController as? UITabBarController,
                let navigationViewController = tabBarController.viewControllers?.first as? UINavigationController,
                let channelsViewController = navigationViewController.viewControllers.first as? ChannelsViewController,
                let channelIndex = channelsViewController.items.firstIndex(whereChannelId: messageReference.channelId,
                                                                           channelType: messageReference.channelType),
                let channelPresenter = channelsViewController.items[channelIndex].channelPresenter {
                channelsViewController.navigationController?.viewControllers = [channelsViewController]
                let chatViewController = channelsViewController.createChatViewController(with: channelPresenter,
                                                                                         indexPath: .row(channelIndex))
                channelsViewController.show(chatViewController: chatViewController)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("🗞📱", "App did register for remote notifications with DeviceToken")
        
        Client.shared.addDevice(deviceToken: deviceToken)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🗞❌", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("🗞📮", userInfo)
    }
}

// MARK: - Test Data
    
extension User {
    static let user1 = User(id: "broken-waterfall-5", name: "Jon Snow", avatarURL: URL(string: "https://bit.ly/2u9Vc0r"))
    static let user2 = User(id: "steep-moon-9", name: "Steep moon")
    static let user3 = User(id: "spring-unit-2", name: "Spring unit")
}

extension Token {
    static let token1 = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiYnJva2VuLXdhdGVyZmFsbC01In0.d1xKTlD_D0G-VsBoDBNbaLjO-2XWNA8rlTm4ru4sMHg"
    static let token2 = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoic3RlZXAtbW9vbi05In0.K7uZEqKmiVb5_Y7XFCmlz64SzOV34hoMpeqRSz7g4YI"
    static let token3 = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoic3ByaW5nLXVuaXQtMiJ9.9v5UwQW1WOG3yGTq3nMI53zg0neR_ZsDtAT--AdbTyY"
}