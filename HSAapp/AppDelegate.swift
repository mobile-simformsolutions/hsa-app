//
//  AppDelegate.swift
//

import UIKit
import Firebase
import FirebaseAnalytics
import Resolver

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Dependencies
    //
    @Injected var analytics: AnalyticsType
    @Injected var userManager: UserManager

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        _ = Logging.shared

//        setupFirebase()
//        setupAnalytics()
        setupRealm()
        return true
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       // Try again later.
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        userManager.logout(clearData: false)
    }
}

// MARK: - Third party dependencies
//
private extension AppDelegate {

    func setupFirebase() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    }

    func setupAnalytics() {
        analytics.initialize()
    }

    func setupRealm() {
        RealmManager.initRealm()
        PersistenceService().reset()
    }
}
