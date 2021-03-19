//
//  TMPauses.swift
//  Tracker
//
//  Created by Marlo Kessler on 09.08.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import RealmSwift

class TMPause: Object {
    
    let classVersion = "1.0"
    
    var parentCategory = LinkingObjects(fromType: TMEvent.self, property: "pauses")
    
    @objc dynamic var startDate = Date()
    @objc dynamic var endDate = Date()
    
    @objc dynamic var pauseTime: [Int] {
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
    
    
    
}
