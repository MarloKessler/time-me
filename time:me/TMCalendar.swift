//
//  TMCalendar.swift
//  time:me
//
//  Created by Marlo Kessler on 04.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import EventKit

class TMCalendar {
    
//    var identifier = ""
    var isSelected = true
    var calendar: EKCalendar
//    var color = CGColor()
    
    init(isSelected: Bool, calendar: EKCalendar/*, color: CGColor*/ ) {
//        self.identifier = identifier
        self.isSelected = isSelected
        self.calendar = calendar
//        self.color = color
    }
    
}
