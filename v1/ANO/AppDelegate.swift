//
//  AppDelegate.swift
//  ANO
//
//  Created by Mychal Culpepper on 16/11/2016.
//  Copyright © 2016 Blue Shift Group. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import SVProgressHUD
import CoreLocation
import AirPlay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AirPlay.startMonitoring()
        
        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        
//        if User.currentUser != nil {
            let mainNC = window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let cameraVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
            
            GlobalService.sharedInstance.cameraVC = cameraVC
            
            mainNC.pushViewController(cameraVC, animated: false)
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let ref = FIRDatabase.database().reference().child("Events")
        ref.observe(.value, with: { (snapshot) in
            GlobalService.sharedInstance.aryEvents.removeAll()
            
            for child in snapshot.children {
                let snapshot = child as! FIRDataSnapshot
                if let dicEvent = snapshot.value as? [String: Any] {
                    GlobalService.sharedInstance.aryEvents.append(Event(key: snapshot.key, json: dicEvent))
                }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Strings.NOTIFICATION_EVENT_UPDATE), object: nil)
        })
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block:{(timer) in
                self.locationManager.startUpdatingLocation()
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            if GlobalService.sharedInstance.userLocation == nil {
                GlobalService.sharedInstance.userLocation = userLocation
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Strings.NOTIFICATION_GOL_LOCATION), object: nil)
            } else {
                GlobalService.sharedInstance.userLocation = userLocation
            }
            manager.stopUpdatingLocation()
        }
    }
}
