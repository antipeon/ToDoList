//
//  SceneDelegate.swift
//  ToDoList
//
//  Created by Samat Gaynutdinov on 26.07.2022.
//

import UIKit
import CocoaLumberjack

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        setUpLogger()

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigationViewController = UINavigationController()

        let networkService = ObservableDefaultNetworkingService(networkService: DefaultNetworkService())
        let observer = NetworkingServiceObserverImpl()
        networkService.observer = observer

        let toDoListViewController = ToDoListViewController(model: ToDoListService(networkService: networkService), observer: observer)

        let oauthController = YandexOauthController()
        navigationViewController.viewControllers = [toDoListViewController, oauthController]
        toDoListViewController.navigationController?.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationViewController

        let style = NSMutableParagraphStyle()

        let navigationBarTitleIndent: CGFloat = 16
        style.firstLineHeadIndent = navigationBarTitleIndent
        UINavigationBar.appearance().largeTitleTextAttributes = [
            NSAttributedString.Key.paragraphStyle: style
        ]

        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func setUpLogger() {
        DDLog.add(DDOSLogger.sharedInstance)
        dynamicLogLevel = DDLogLevel.verbose
    }

}
