//
//  TMEvent.swift
//  time:me
//
//  Created by Marlo Kessler on 15.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import RealmSwift
import EventKit


class TMEvent: Object {
    
    let classVersion = "1.0"
    
    @objc dynamic var calendarItemExternalIdentifier = ""
    
    @objc dynamic var title = ""
    
    @objc dynamic var eventStartDate = Date()
    @objc dynamic var eventEndDate = Date()
    
    @objc dynamic var startDate = Date()
    @objc dynamic var endDate = Date()
    
    @objc dynamic var startDay = Date()
    @objc dynamic var endDay = Date()
    
    @objc dynamic var location = ""
    
    @objc dynamic var status: Status = .notTracking
    
    var pauses = List<TMPause>()
    @objc dynamic var pauseTime: [Int] {
        get {
            
            var pauseTime = [0,0,0,0,0,0] //[years, months, days, hours, minutes, seconds]
            
            for pause in pauses {
                
                pauseTime[0] += pause.pauseTime[0]
                pauseTime[1] += pause.pauseTime[1]
                pauseTime[2] += pause.pauseTime[2]
                pauseTime[3] += pause.pauseTime[3]
                pauseTime[4] += pause.pauseTime[4]
                pauseTime[5] += pause.pauseTime[5]
            }
            
            return pauseTime
        }
    }
    
    @objc dynamic var trackedTime: [Int] {
        get {
            
            let years = endDate.years(from: startDate)
            let months = endDate.months(from: startDate) % 12
            let days = endDate.days(from: startDate) % 30
            let hours = endDate.hours(from: startDate) % 24
            let minutes = endDate.minutes(from: startDate) % 60
            let seconds = endDate.seconds(from: startDate) % 60
            
            return [years, months, days, hours, minutes, seconds]
        }
    }
    
    @objc dynamic var workTime: [Int] {
        get {
            
            let years = trackedTime[0] - pauseTime[0]
            let months = trackedTime[1] - pauseTime[1]
            let days = trackedTime[2] - pauseTime[2]
            let hours = trackedTime[3] - pauseTime[3]
            let minutes = trackedTime[4] - pauseTime[4]
            let seconds = trackedTime[5] - pauseTime[5]
            
            return [years, months, days, hours, minutes, seconds]
        }
    }
    
    @objc dynamic var calendarID = ""
    @objc dynamic var calendarTitle = ""
    @objc dynamic var calendarColorHexValue = "00a3ff"
    
    var parentCategory = LinkingObjects(fromType: TMProject.self, property: "events")
    
    @objc enum Status: Int {
        case notTracking = 0
        case isTracking = 1
        case finishedTracking = 2
        case isPausing = 3
    }
    
    @objc dynamic func copyFrom(tmEvent: TMEvent) {
        title = tmEvent.title
        calendarColorHexValue = tmEvent.calendarColorHexValue
        calendarID = tmEvent.calendarID
        calendarItemExternalIdentifier = tmEvent.calendarItemExternalIdentifier
        calendarTitle = tmEvent.calendarTitle
        endDate = tmEvent.endDate
        endDay = tmEvent.endDay
        eventEndDate = tmEvent.eventEndDate
        eventStartDate = tmEvent.eventStartDate
        location = tmEvent.location
        startDate = tmEvent.startDate
        startDay = tmEvent.startDay
        status = tmEvent.status
    }
    
    @objc dynamic func copyFrom(ekEvent: EKEvent) {
        calendarItemExternalIdentifier = ekEvent.eventIdentifier
        
        title = ekEvent.title
        
        eventStartDate = ekEvent.startDate
        eventEndDate = ekEvent.endDate
        
        startDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: ekEvent.startDate)!
        endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: ekEvent.endDate)!
        
        location = ekEvent.location ?? ""
        
        calendarID = ekEvent.calendar.calendarIdentifier
        calendarTitle = ekEvent.calendar.title
        calendarColorHexValue = UIColor(cgColor: ekEvent.calendar.cgColor).hexValue()
    }
    
}
