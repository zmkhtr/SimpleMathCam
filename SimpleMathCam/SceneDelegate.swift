//
//  SceneDelegate.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 09/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var navigationController = UINavigationController()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        let flow = AppFlow(navigationController: navigationController)
        flow.start()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

