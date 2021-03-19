//
//  LocalNotificationManager.swift
//  time:me
//
//  Created by Marlo Kessler on 11.07.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import UserNotifications



class LocalNotificationManager {
    
    
    private var notifications = [Notification]()
    
    
    
    func listScheduledNotifications() {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    
    
    func schedule(notifications: [Notification]) {
        self.notifications = notifications
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    
    
    private func scheduleNotifications() {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.subtitle = notification.subtitle ?? ""
            content.body = notification.body ?? ""
            
            content.summaryArgument = notification.summaryArgument
            content.summaryArgumentCount = notification.summaryArgumentCount
            content.threadIdentifier = notification.threadIdentifier
            content.userInfo = notification.userInfo ?? [AnyHashable: Any]()
            
            content.attachments = notification.attachments ?? [UNNotificationAttachment]()
            content.sound = notification.sound ?? .default
            content.launchImageName = notification.launchImageName ?? ""
            
            DispatchQueue.main.async {
                content.badge = NSNumber(value: (UIApplication.shared.applicationIconBadgeNumber + 1))
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard error == nil else { return }
                
                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
    
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    
    func cancelNotifications(notifications: [Notification]) {
        
        var ids = [String]()
        
        for notification in notifications {
            ids.append(notification.id)
        }
        
        cancelNotifications(notificationIDs: ids)
    }
    
    
    
    func cancelNotifications(notificationIDs: [String]) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }
}
