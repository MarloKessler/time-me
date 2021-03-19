//
//  File.swift
//  time:me
//
//  Created by Marlo Kessler on 18.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}




//extension UIColor {
//    
//    func hexValue() -> String {
//        
//        var currentColor = self
//        
//        if CGColor.numberOfComponents(self.cgColor) < 4 {
//            CGColor.
//            let components = CGColor.components(self.CGColor)
//            currentColor = UIColor(red: components[0], green: components[0], blue: components[0], alpha: components[1])
//        }
//        
//        if (CGColorSpaceGetModel(CGColorGetColorSpace(currentColor.CGColor)) != kCGColorSpaceModelRGB) {
//            
//            return [NSString stringWithFormat:@"#FFFFFF"];
//        }
//        
//        return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(currentColor.CGColor))[0]*255.0), (int)((CGColorGetComponents(currentColor.CGColor))[1]*255.0), (int)((CGColorGetComponents(currentColor.CGColor))[2]*255.0)];
//        
//    }
//}
