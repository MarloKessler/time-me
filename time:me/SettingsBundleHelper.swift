//
//  SettingsBundleHelper.swift
//  time:me
//
//  Created by Marlo Kessler on 12.07.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation

//protocol SettingsBundleHelperDelegate {
//    func notificationTimeDidChange(newDifference: Int)
//}

struct SettingsBundleHelper {
    
    let defaults = UserDefaults.init(suiteName: "group.timeme.defaults")!
    
//    var delegate: SettingsBundleHelperDelegate?
//
//
//
//    init(delegate: SettingsBundleHelperDelegate? = nil) {
//
//        self.delegate = delegate
//        self.delegate?.notificationTimeDidChange(newDifference: getNotificationTime())
//    }
    
    
    
//    func observeNotificationTime() {
//
//        let _ = defaults.observe(\.notificationTime, options: [.initial, .new], changeHandler: { (defaults, change) in
//            self.defaultsDidChange()
//        })
//    }
    
    
    
//    private func defaultsDidChange() {
//
//        delegate?.notificationTimeDidChange(newDifference: getNotificationTime())
//    }
    
    
    
    func getNotificationTime() -> Int {
        
        //Delivers the new notificationTime value
        let newNotificationTimeValue = defaults.integer(forKey: "notification_time_preference")
        
        switch newNotificationTimeValue {
        case 1:
            return 0
        case 2:
            return 5
        case 3:
            return 10
        case 4:
            return 15
        case 5:
            return 20
        case 6:
            return 30
        case 7:
            return 45
        case 8:
            return 60
        case 9:
            return 120
        case 10:
            return 300
        case 11:
            return 1440
        default:
            return 10
        }
    }
    
    
    
    func setVersionAndBuildNumber() {
        
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        defaults.set(version, forKey: "version_number_preference")
    }
}
