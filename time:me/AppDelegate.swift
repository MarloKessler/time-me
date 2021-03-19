//
//  AppDelegate.swift
//  time:me
//
//  Created by Marlo Kessler on 20.11.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import RealmSwift
import UserNotifications
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    let productID = "com.timeme.timeme.timeme_plus"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Prepares Realm
        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.timeme.realm")!
        directory = directory.appendingPathComponent("trackedevents.realm")
        Realm.Configuration.defaultConfiguration.fileURL = directory
        
        do {
            
            _ = try Realm()
        } catch {}
        
        
        SKPaymentQueue.default().add(self)
        
        
        //Prepares the SplitViewController
        guard let splitViewController = window?.rootViewController as? UISplitViewController,
            let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
            let masterViewController = leftNavController.topViewController as? MainViewController,
            let rightNavViewController = splitViewController.viewControllers.last as? UINavigationController,
            let detailViewController = rightNavViewController.topViewController as? EventViewController
            else { fatalError() }
        
        splitViewController.delegate =  self
        splitViewController.preferredDisplayMode = .allVisible
//        detailViewController.navigationItem.leftItemsSupplementBackButton = true
//        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
//
        masterViewController.delegate = detailViewController
        detailViewController.delegate = masterViewController
        
//        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//
//            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
        
        
        
        //MARK: - UISplitViewControllerDelegate function; is responsible, that the masterView shows up first instead of the detailView on iPhone
        func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
            return true
        }
        
        
        
        @objc func rotated() {
                
            guard let splitViewController = window?.rootViewController as? UISplitViewController,
                let rightNavViewController = splitViewController.viewControllers.last as? UINavigationController,
                let detailViewController = rightNavViewController.topViewController as? EventViewController
                else { fatalError() }
            
            if UIDevice.current.orientation.isLandscape {
                splitViewController.preferredDisplayMode = .allVisible
                detailViewController.navigationItem.leftItemsSupplementBackButton = false
                detailViewController.navigationItem.leftBarButtonItem = nil
            }
            
            if UIDevice.current.orientation.isPortrait {
                splitViewController.preferredDisplayMode = .allVisible
                detailViewController.navigationItem.leftItemsSupplementBackButton = true
                detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            }
        }
        
        
        
        //MARK: - Functions to enable App Store in-app purchases
        func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
            
            guard let splitViewController = window?.rootViewController as? UISplitViewController,
                let leftNavController = splitViewController.viewControllers.first as? UINavigationController,
                let masterViewController = leftNavController.topViewController as? MainViewController
                else { fatalError() }
            
            masterViewController.performSegue(withIdentifier: "goToBuyView", sender: self)
            
            return false
        }
        
        
        
        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {}
    }

