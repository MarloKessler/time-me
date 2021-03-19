//
//  Notification.swift
//  time:me
//
//  Created by Marlo Kessler on 11.07.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import UserNotifications



struct Notification {
    var id: String
    
    var notificationType: NotificationType
    
    var title: String
    var subtitle: String?
    var body: String?
    
    var datetime: DateComponents
    
    
    var summaryArgument: String {
        get {
            switch notificationType {
            case .eventNotification:
                return "Anstehende Termine"
            case .defaultNotification:
                return "time:me"
            }
        }
    }
    var summaryArgumentCount: Int {
        get {
            return 1
        }
    }
    var threadIdentifier: String  {
        get {
            switch notificationType {
            case .eventNotification:
                return "EVENT_NOTIFICATIONS"
            case .defaultNotification:
                return "TIME_ME"
            }
        }
    }
    
    //    var categoryIdentifier: String {
    //        get {
    //            return "eventNotification"
    //        }
    //    }
    
    var userInfo: [AnyHashable: Any]?
    var attachments: [UNNotificationAttachment]?
    var sound: UNNotificationSound?
    var launchImageName: String?
    
    enum NotificationType {
        case eventNotification
        case defaultNotification
    }
    
    
    init(id: String, notificationType: NotificationType, title: String, subtitle: String? = nil, body: String? = nil, datetime: DateComponents, userInfo: [AnyHashable: Any]? = nil, attachments: [UNNotificationAttachment]? = nil, sound: UNNotificationSound? = nil, launchImageName: String? = nil) {
        
        self.id = id
        self.notificationType = notificationType
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.datetime = datetime
        self.userInfo = userInfo
        self.attachments = attachments
        self.sound = sound
        self.launchImageName = launchImageName
    }
}
