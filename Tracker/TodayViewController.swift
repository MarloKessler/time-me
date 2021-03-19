//
//  TodayViewController.swift
//  Tracker
//
//  Created by Marlo Kessler on 08.07.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift
import EventKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startEndTimeStack: UIStackView!
    @IBOutlet weak var stopWatchViewTitle: UILabel!
    @IBOutlet weak var stopWatchLabel: UILabel!
    @IBOutlet weak var stopWatchView: UIView!
    @IBOutlet weak var stopWatchViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var stopWatchButton: UIButton!
    @IBOutlet weak var stopWatchCancelButton: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var buttonStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noEventView: UIView!
    @IBOutlet weak var demoVersionOverLabel: UILabel!
    
    var realm = try! Realm()
    let eventStore = EKEventStore()
    let defaults = UserDefaults.init(suiteName: "group.timeme.defaults")!
    let selectedCalKey = "selectedCalendars"
    let firstLaunchingDate = "firstLaunchingDate"
    
    let widgetController = NCWidgetController()
//    var shouldDisappearWhenNoContent = true
    
    let productID = "com.timeme.timeme.timeme_plus"
    let demoDays = 60
    
    var timer = Timer()
    
//    let greenHexCode = "229E33"
    let greenUIColor = UIColor(red: 34/255, green: 158/255, blue: 51/255, alpha: 1)
//    let redHexCode = "FF2600"
    let redUIColor = UIColor(red: 1, green: 38/255, blue: 0, alpha: 1)
//    let blueHexCode = "3579F6"
//    let blueUIColor = UIColor(red: 53/255, green: 121/255, blue: 246/255, alpha: 1)
    
    var tmEvent = TMEvent()
    var tmEventCopy = TMEvent()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        stopWatchButton.layer.cornerRadius = 5

        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.timeme.realm")!
        directory = directory.appendingPathComponent("trackedevents.realm")
        print("AbsolutPath: " + directory.absoluteString)
        Realm.Configuration.defaultConfiguration.fileURL = directory

        realm = try! Realm()

        updateWidgetVisibility()
    }
    
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
//        updateWidgetVisibility()
        reloadUI()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let date = defaults.object(forKey: firstLaunchingDate)
        print(date ?? "No Value")
        
        if defaults.bool(forKey: productID) || Date().days(from: date as! Date) < demoDays {
            print("default value for productID is true")
            demoVersionOverLabel.isHidden = true
            
            updateWidgetVisibility()
            
            if getEvent() != nil {
                
                if activeDisplayMode == .compact {
                    
                    prepareSmallView(for: tmEvent, maxSize: maxSize)
                } //else if activeDisplayMode == .expanded {
                //
                //                prepareLargeView(for: tmEvent, maxSize: maxSize)
                //            }
                
            }
            
        } else {
            
            print("date difference is more than 3 month and product is not bought")
            
            titleLabel.isHidden = true
            startEndTimeStack.isHidden = true
            stopWatchView.isHidden = true
            buttonStack.isHidden = true
            noEventView.isHidden = true
            
            //The text is formatted like this due to studies that show, those texts perform better.
            demoVersionOverLabel.text = NSLocalizedString("demoversion over", comment: "")
            
            demoVersionOverLabel.isHidden = false
        }
    }
    
    
    
    @IBAction func stopWatchButtonPressed(_ sender: UIButton) {
        
        switch tmEvent.status {
            
        case .notTracking:
            tmEvent.startDate = Date()
            tmEvent.endDate = tmEvent.startDate
            tmEvent.status = .isTracking
            
            try! realm.write {
                realm.add(tmEvent)
            }
            print("Event Added")
            
            reloadUI()
            
        case .isTracking:
            timer.invalidate()
            
            try! realm.write {
                
                tmEvent.endDate = Date()
                tmEvent.status = .finishedTracking
                print("Event changed")
            }
            
            reloadUI()
            
        case .finishedTracking:
            print("GO TO EDIT EVENT")
        
        case .isPausing:
            print("is Pausing")
        }
    }
    
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        self.timer.invalidate()
        
        try! self.realm.write {
            self.realm.delete(self.tmEvent)
        }
        
        self.tmEvent = TMEvent()
        self.tmEvent.copyFrom(tmEvent: self.tmEventCopy)
        
        self.tmEvent.status = .notTracking
        self.reloadUI()
    }
    
    
    
    //Forces the UI to reload
    func reloadUI() {
        
        self.widgetActiveDisplayModeDidChange(self.extensionContext!.widgetActiveDisplayMode, withMaximumSize: self.extensionContext!.widgetMaximumSize(for: self.extensionContext!.widgetActiveDisplayMode))
    }
    
    
    
    //Diables the Widget if no Event is available
    func updateWidgetVisibility() {
        
        if let tmEvent = getEvent() {
            print("Found Event")
            self.tmEvent = tmEvent
            self.tmEventCopy.copyFrom(tmEvent: tmEvent)
            
            self.widgetController.setHasContent(true, forWidgetWithBundleIdentifier: "com.timeme.time-me.Time-Me-Tracker")
            
            titleLabel.isHidden = false
            startEndTimeStack.isHidden = false
            stopWatchView.isHidden = false
            buttonStack.isHidden = false
            
            noEventView.isHidden = true
            
        } else {
            print("No Event Found")
            
            titleLabel.isHidden = true
            startEndTimeStack.isHidden = true
            stopWatchView.isHidden = true
            buttonStack.isHidden = true
            
            noEventView.isHidden = false
            
//            self.widgetController.setHasContent(false, forWidgetWithBundleIdentifier: "com.timeme.time-me.Time-Me-Tracker")
        }
    }
    
    
    
    //Gets the current tmEvent within an hour range
    func getEvent() -> TMEvent? {
        
        var tmEvents = realm.objects(TMEvent.self)
        print("\(tmEvents.count) tmEvents found")
        //Searching in TMEvents
        for tmEvent in tmEvents {
            
            if tmEvent.status == .isTracking {
                
                return tmEvent
            }
        }
        
        //Searching an close EKEvent
        var calendars = [EKCalendar]()
        
        if let selectedCalendars = defaults.array(forKey: selectedCalKey) as? [String] {
            
            for id in selectedCalendars {
                
                if let calendar = eventStore.calendar(withIdentifier: id) {
                    print("Calendar is: \(calendar.title)")
                    calendars.append(calendar)
                }
            }
            
            print("Found \(calendars.count) Calendars")
        } else {
            print("calendar defaults are nil")
        }
        
        if !calendars.isEmpty {
            
            let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
            
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            var ekEvents = eventStore.events(matching: predicate)
            print("Found \(ekEvents.count) Events")
            
            //Remove EKEvents where exists an TMEvent
            for tmEvent in tmEvents {
                
                var position = 0
                
                for ekEvent in ekEvents {
                    
                    if tmEvent.title == ekEvent.title && tmEvent.eventStartDate == ekEvent.startDate && tmEvent.eventEndDate == ekEvent.endDate {
                        print("\(ekEvents[position].title ?? "Ein") (EKE) gelöscht")
                        ekEvents.remove(at: position)
                    }
                    
                    position += 1
                }
            }
            
            //Remove all ekEvents which are more than an hour away from current date
            var position = 0
            for ekEvent in ekEvents {
                
                if abs(ekEvent.startDate.hours(from: Date())) > 1 && abs(ekEvent.endDate.hours(from: Date())) > 1 {
                    
                    ekEvents.remove(at: position)
                }
                
                position += 1
            }
            
            
            //Search in ekEvents
            if !ekEvents.isEmpty {
                
                var oldEKEvent = ekEvents[0]
                
                for ekEvent in ekEvents {
                    
                    if abs(ekEvent.startDate.minutes(from: Date())) < abs(oldEKEvent.startDate.minutes(from: Date())) {
                        
                        oldEKEvent = ekEvent
                    } else {
                        
                        let event = TMEvent()
                        event.copyFrom(ekEvent: oldEKEvent)
                        
                        return event
                    }
                }
            } else {
                print("ekEvents are empty")
            }
        } else {
            print("calendars are empty")
        }
        
        //Gets the last tracked Event if it is not longer than an hour ago
        tmEvents = tmEvents.sorted(byKeyPath: "eventEndDate")
        let lastTMEvent = tmEvents.sorted(byKeyPath: "eventEndDate").last
        if lastTMEvent != nil && abs(Date().hours(from: lastTMEvent!.eventEndDate)) < 1  {
            
            print("\(abs(Date().hours(from: lastTMEvent!.eventEndDate)))")
            return lastTMEvent
        }
        
        print("returned nil")
        return nil
    }
    
    
    
    func prepareLargeView(for tmEvent: TMEvent, maxSize: CGSize) {
        
        titleLabel.text = tmEvent.title
        
        stopWatchViewTopContraint.constant = 128
        stopWatchViewTitle.isHidden = false
        
        switch tmEvent.status {
            
        case .notTracking:
            timer.invalidate()
            
            self.preferredContentSize = CGSize(width: maxSize.width, height: 130)
            
            startTimeLabel.text = "--:--"
            endTimeLabel.text = "--:--"
            startEndTimeStack.isHidden = true
            
            stopWatchView.isHidden = true
            stopWatchLabel.text = "00 : 00"
            
            stopWatchButton.setTitle(NSLocalizedString("start tracking", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(.white, for: .normal)
            stopWatchButton.backgroundColor = greenUIColor
            stopWatchButton.layer.borderWidth = 0
            stopWatchButton.layer.shadowRadius = 5
            
            stopWatchCancelButton.isHidden = true
            
            buttonStackTopConstraint.constant = 16
            buttonStackHeightConstraint.constant = 70
            
            
        case .isTracking:
            self.preferredContentSize = CGSize(width: maxSize.width, height: 550)
            
            startEndTimeStack.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            startTimeLabel.text = dateFormatter.string(from: tmEvent.startDate)
            endTimeLabel.text = "--:--"
            
            stopWatchView.isHidden = false
//            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerForStopWatchLabel), userInfo: nil, repeats: true)
            
            stopWatchButton.setTitle(NSLocalizedString("stop tracking", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(.white, for: .normal)
            stopWatchButton.backgroundColor = redUIColor
            stopWatchButton.layer.borderWidth = 0
            stopWatchButton.layer.shadowRadius = 5
            
            stopWatchCancelButton.isHidden = false
            
            stopWatchCancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
//            stopWatchCancelButton.setTitleColor(UIColor(hexString: blueHexCode), for: .normal)
            
            buttonStackTopConstraint.constant = 328
            buttonStackHeightConstraint.constant = 140
            
            
        case .finishedTracking:
            timer.invalidate()
            
            self.preferredContentSize = CGSize(width: maxSize.width, height: 410)
            
            startEndTimeStack.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            startTimeLabel.text = dateFormatter.string(from: tmEvent.startDate)
            endTimeLabel.text = dateFormatter.string(from: tmEvent.endDate)
            
            stopWatchLabel.isHidden = false
            updateStopWatchLabel(startDate: tmEvent.startDate, endDate: tmEvent.endDate)
            
            buttonStack.isHidden = true //Delete this and resize preferedContentSize if EDIT button should be enabled
            
            //            stopWatchButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
//            stopWatchButton.setTitleColor(UIColor(hexString: blueHexCode), for: .normal)
//            stopWatchButton.backgroundColor = UIColor(hexString: "ffffff", withAlpha: 0.5)
//            stopWatchButton.layer.borderColor = UIColor(hexString: blueHexCode)?.cgColor
//            stopWatchButton.layer.borderWidth = 1
//            stopWatchButton.layer.shadowRadius = 0
//
//            stopWatchCancelButton.isHidden = true
//            buttonStackHeightConstraint.constant = 70
            
        case .isPausing:
            print("is Pausing")
        }
    }
    
    
    
    @objc func timerForStopWatchLabel() {
        updateStopWatchLabel(startDate: tmEvent.startDate, endDate: Date())
    }
    
    
    
    func prepareSmallView(for tmEvent: TMEvent, maxSize: CGSize) {
        
        self.preferredContentSize = CGSize(width: maxSize.width, height: 110)
        
        titleLabel.text = tmEvent.title
        
        startEndTimeStack.isHidden = true
        
        stopWatchView.isHidden = false
        stopWatchViewTopContraint.constant = -75
        stopWatchViewTitle.isHidden = true
        
        buttonStackTopConstraint.constant = 10
        buttonStackHeightConstraint.constant = 50
        
        stopWatchButton.layer.borderWidth = 0
        stopWatchButton.layer.shadowRadius = 5
        
        stopWatchCancelButton.isHidden = true
        
        switch tmEvent.status {
            
        case .notTracking:
            timer.invalidate()
            
            stopWatchLabel.isHidden = true
            
            buttonStack.isHidden = false
            
            stopWatchButton.setTitle(NSLocalizedString("start tracking", comment: ""), for: .normal)
            stopWatchButton.backgroundColor = greenUIColor
            
        case .isTracking:
            timer.invalidate()
            
            stopWatchLabel.isHidden = true
            
            buttonStack.isHidden = false
            
            stopWatchButton.setTitle(NSLocalizedString("stop tracking", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(.white, for: .normal)
            stopWatchButton.backgroundColor = redUIColor
            
        case .finishedTracking:
            timer.invalidate()
            
            stopWatchLabel.isHidden = false
            updateStopWatchLabel(startDate: tmEvent.startDate, endDate: tmEvent.endDate)
            
            buttonStack.isHidden = true
            
        case .isPausing:
            print("is Pausing")
        }
    }
    
    
    
    func updateStopWatchLabel(startDate: Date, endDate: Date) {
        
        let hours = endDate.hours(from: startDate)
        let stringHours = hours > 9 ? "\(hours)" : "0\(hours)"
        
        let minutes = (endDate.minutes(from: startDate) % 60)
        let stringMinutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        let seconds = (endDate.seconds(from: startDate) % 60)
        let stringSeconds = seconds  > 9 ? "\(seconds)" : "0\(seconds)"
        
        stopWatchLabel.text = hours == 0 ? "\(stringMinutes) : \(stringSeconds)" : "\(stringHours) : \(stringMinutes) : \(stringSeconds)"
    }
    
    
    
    func checkBuyStatus() {
        
        
    }
    
    
    
}
