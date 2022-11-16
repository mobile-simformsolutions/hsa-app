//
//  SceneDelegate.swift
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Variables
    //
    static var activeWindow: UIWindow?
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        // Use a UIHostingController as window root view controller
        let window = UIWindow(windowScene: scene as! UIWindowScene) // swiftlint:disable:this force_cast
        self.window = window
        SceneDelegate.activeWindow = window
        SceneDelegate.setRootController(to: AnyView(SplashView()))
    }

    static func setRootController(to newRoot: AnyView) {
        if let window = SceneDelegate.activeWindow {
            window.rootViewController = HostingController(rootView: newRoot)
            window.makeKeyAndVisible()
        }
    }
}
