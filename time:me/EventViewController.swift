//
//  EventViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 10.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift


enum TrackingStatus {
    case notStartedYet
    case started
    case stopped
}


protocol EventViewDelegate {
    func eventViewWasDismissed()
}



class EventViewController: UIViewController, EditEventDelegate, MainViewControllerDelegate {
    
    
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startEndTimeStack: UIStackView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var stopWatchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopWatchLabelHeading: UILabel!
    @IBOutlet weak var stopWatchLabel: UILabel!
    @IBOutlet weak var stopWatchButton: UIButton!
    @IBOutlet weak var stopWatchButtonHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopWatchCancelButton: UIButton!
    @IBOutlet weak var noEventAvailableView: UIView!
    
    var delegate: EventViewDelegate?
    
    var event: Any? {
        
        didSet {
            
            if let ekEvent = event as? EKEvent {
                
                tmEvent = TMEvent()
                tmEvent!.copyFrom(ekEvent: ekEvent)
                
                if let view = noEventAvailableView {
                    
                    view.isHidden = true
                    tmEventInit()
                }
            } else if let tmEv = event as? TMEvent {
                
                tmEvent = tmEv
                if let view = noEventAvailableView {
                    view.isHidden = true
                    tmEventInit()
                }
            } else {
                if let view = noEventAvailableView {
                    view.isHidden = false
                    navTitle.title = nil
                }
            }
        }
    }
    var tmEvent: TMEvent?
    var tmEventCopy = TMEvent()
    
    var timer = Timer()
    var stopWatchTimerLabel = UILabel()
    
    let greenHexCode = "229E33"
    let redHexCode = "FF2600"
    let blueHexCode = "3579F6"
    
    var realm = try! Realm()
    var realmToken: NotificationToken?
    let eventStore = EKEventStore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.timeme.realm")!
        directory = directory.appendingPathComponent("trackedevents.realm")
        Realm.Configuration.defaultConfiguration.fileURL = directory
        
        realm = try! Realm()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if tmEvent != nil {
            
            noEventAvailableView.isHidden = true
            stopWatchTimerLabel = stopWatchLabel
            tmEventInit()
            print(tmEvent!.pauses.count)
            print(tmEvent!.pauseTime)
            print(tmEvent!.trackedTime)
            print(tmEvent!.workTime)
        } else {
            
            noEventAvailableView.isHidden = false
        }
    }
    
    
    
    func tmEventInit() {
        
        tmEventCopy.copyFrom(tmEvent: tmEvent!)
        
        navTitle.title = tmEvent!.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tmEvent!.eventStartDate) == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tmEvent!.eventEndDate) ? .none : .short
        
        switch NSLocale.current.languageCode {
        case "de":
            dateFormatter.locale = Locale.current
            
            startDateLabel.text = NSLocalizedString("from", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventStartDate) +  " " + NSLocalizedString("clock", comment: "")
            endDateLabel.text = NSLocalizedString("until", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventEndDate) +  " " + NSLocalizedString("clock", comment: "")
            
        case "en":
            dateFormatter.locale = Locale.current
            
            startDateLabel.text = NSLocalizedString("from", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventStartDate)
            endDateLabel.text = NSLocalizedString("until", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventEndDate)
            
        default:
            dateFormatter.locale = Locale.current
            
            startDateLabel.text = NSLocalizedString("from", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventStartDate)
            endDateLabel.text = NSLocalizedString("until", comment: "") +  " " + dateFormatter.string(from: tmEvent!.eventEndDate)
        }
        
        
        setPageOnTMEventStatus(status: tmEvent!.status)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        timer.invalidate()
        
        if self.isMovingFromParent {
            
            delegate?.eventViewWasDismissed()
        }
    }
    
    
    
    @IBAction func stopWatchButtonPressed(_ sender: UIButton) {
        
        tmEventCopy.copyFrom(tmEvent: tmEvent!)
        
        switch tmEvent!.status {
            
        case .notTracking:
//            try! realm.write {
                tmEvent!.startDate = Date()
                tmEvent!.endDate = tmEvent!.startDate
                tmEvent!.status = .isTracking
//            }
            
            try! realm.write {
                realm.add(tmEvent!)
            }
//            addTMEventObserver()
                
            setPageOnTMEventStatus(status: tmEvent!.status)
            
        case .isTracking:
            
            timer.invalidate()
            
            try! realm.write {
                
                tmEvent!.endDate = Date()
                tmEvent!.status = .finishedTracking
            }
            
            setPageOnTMEventStatus(status: tmEvent!.status)
            
        case .finishedTracking:
            performSegue(withIdentifier: "goToEditTMEvent", sender: self)
            
        case .isPausing:
            print("is pausing")
        }
        
        tmEventCopy.copyFrom(tmEvent: tmEvent!)
    }
    
    
    
    func setPageOnTMEventStatus(status: TMEvent.Status) {
        
        switch status {
            
        case .notTracking:
            
            timer.invalidate()
            stopWatchTimerLabel = UILabel()
            
            startTimeLabel.text = "--:--"
            endTimeLabel.text = "--:--"
            
            startEndTimeStack.isHidden = true
            
            stopWatchViewTopConstraint.constant = 0
            
            stopWatchLabelHeading.isHidden = true
            stopWatchLabel.isHidden = true
            stopWatchLabel.text = "00 : 00"
            
            stopWatchButton.setTitle(NSLocalizedString("start time tracking", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(UIColor(hexString: "ffffff"), for: .normal)
            stopWatchButton.backgroundColor = UIColor(hexString: greenHexCode)
            stopWatchButton.layer.borderWidth = 0
            stopWatchButton.layer.cornerRadius = 5
            stopWatchButton.layer.shadowRadius = 5
            
            stopWatchButtonHorizontalConstraint.constant = 0
            
            stopWatchCancelButton.isHidden = true
            
            
        case .isTracking:
            startEndTimeStack.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            startTimeLabel.text = dateFormatter.string(from: tmEvent!.startDate)
            endTimeLabel.text = "--:--"
            
            stopWatchViewTopConstraint.constant = 120
            
            stopWatchLabelHeading.isHidden = false
            
            stopWatchLabel.isHidden = false
            updateStopWatchLabel(for: stopWatchLabel, endDate: Date())
            stopWatchTimerLabel = stopWatchLabel
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerForStopWatchLabel), userInfo: nil, repeats: true)
            
            stopWatchButton.setTitle(NSLocalizedString("stop time tracking", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(UIColor(hexString: "ffffff"), for: .normal)
            stopWatchButton.backgroundColor = UIColor(hexString: redHexCode)
            stopWatchButton.layer.borderWidth = 0
            stopWatchButton.layer.cornerRadius = 5
            stopWatchButton.layer.shadowRadius = 5
            
            stopWatchButtonHorizontalConstraint.constant = 50
            
            stopWatchCancelButton.isHidden = false
            stopWatchCancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
            stopWatchCancelButton.setTitleColor(UIColor(hexString: blueHexCode), for: .normal)
            
            
        case .finishedTracking:
            timer.invalidate()
            stopWatchTimerLabel = UILabel()
            
            startEndTimeStack.isHidden = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            startTimeLabel.text = dateFormatter.string(from: tmEvent!.startDate)
            endTimeLabel.text = dateFormatter.string(from: tmEvent!.endDate)
            
            stopWatchViewTopConstraint.constant = 120
            
            stopWatchLabelHeading.isHidden = false
            
            stopWatchLabel.isHidden = false
            updateStopWatchLabel(for: stopWatchLabel, endDate: tmEvent!.endDate)
            
            stopWatchButton.setTitle(NSLocalizedString("edit", comment: ""), for: .normal)
            stopWatchButton.setTitleColor(UIColor(hexString: blueHexCode), for: .normal)
            stopWatchButton.backgroundColor = UIColor(hexString: "ffffff", withAlpha: 0.5)
            stopWatchButton.layer.borderColor = UIColor(hexString: blueHexCode)?.cgColor
            stopWatchButton.layer.borderWidth = 1
            stopWatchButton.layer.cornerRadius = 5
            stopWatchButton.layer.shadowRadius = 0
            
            stopWatchButtonHorizontalConstraint.constant = 50
            
            stopWatchCancelButton.isHidden = false
            stopWatchCancelButton.setTitle(NSLocalizedString("delete tracking title", comment: ""), for: .normal)
            stopWatchCancelButton.setTitleColor(UIColor(hexString: redHexCode), for: .normal)
            
        case .isPausing:
            print("is pausing")
        }
    }
    
    
    
    @objc func timerForStopWatchLabel() {
        print("timer is executed")
        updateStopWatchLabel(for: stopWatchTimerLabel, endDate: Date())
    }
    
    
    
    func updateStopWatchLabel(for label: UILabel, endDate: Date) {
        
        let hours = endDate.hours(from: tmEventCopy.startDate)
        let stringHours = hours > 9 ? "\(hours)" : "0\(hours)"
        
        let minutes = (endDate.minutes(from: tmEventCopy.startDate) % 60)
        let stringMinutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        let seconds = (endDate.seconds(from: tmEventCopy.startDate) % 60)
        let stringSeconds = seconds  > 9 ? "\(seconds)" : "0\(seconds)"
        
        label.text = hours == 0 ? "\(stringMinutes) : \(stringSeconds)" : "\(stringHours) : \(stringMinutes) : \(stringSeconds)"
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToEditTMEvent" {
            
            let navVC = segue.destination as! UINavigationController
            
            let destinationVC = navVC.topViewController as! EditTMEventViewController
            
            destinationVC.editEventDelegate = self
            destinationVC.tmEvent = tmEvent!
        }
    }
    
    
    
    @IBAction func cancelOrDeleteEvent(_ sender: UIButton) {
        
        var title = ""
        var message = ""
        var cancelOrDeleteText = ""
        var notCancelOrDeleteText = ""
        
        if tmEvent!.status == .isTracking {
            
            title = NSLocalizedString("cancel tracking title", comment: "")
            message = NSLocalizedString("cancel tracking description", comment: "")
            cancelOrDeleteText = NSLocalizedString("cancel", comment: "")
            notCancelOrDeleteText = NSLocalizedString("dont cancel", comment: "")
            
        } else if tmEvent!.status == .finishedTracking {
            
            title = NSLocalizedString("delete tracking title", comment: "")
            message = NSLocalizedString("delete tracking description", comment: "")
            cancelOrDeleteText = NSLocalizedString("delete", comment: "")
            notCancelOrDeleteText = NSLocalizedString("dont delete", comment: "")
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelOrDelete = UIAlertAction(title: cancelOrDeleteText, style: .destructive) { (action) in
            
            self.timer.invalidate()
            
            try! self.realm.write {
                self.realm.delete(self.tmEvent!)
            }
            
            self.tmEvent = TMEvent()
            self.tmEvent!.copyFrom(tmEvent: self.tmEventCopy)
            self.tmEvent!.status = .notTracking
            
            self.setPageOnTMEventStatus(status: self.tmEvent!.status)
        }
        alert.addAction(cancelOrDelete)
        
        let notCancelOrDelete = UIAlertAction(title: notCancelOrDeleteText, style: .cancel, handler: nil)
        alert.addAction(notCancelOrDelete)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func addTMEventObserver() {
        
        realmToken = tmEvent!.observe({ (change) in
            
            switch change {
            case .change(_):
                self.setPageOnTMEventStatus(status: self.tmEvent!.status)
                
            case .deleted, .error(_):
                break
            }
        })
    }
    
    
    
    //MARK: - EditEventDelegate function
    func eventEdited() {
        
        tmEventInit()
    }
    
    
    
    //MARK: - MainViewControllerDelegate function
    func eventChanged(event: Any?) {
        let e = event as? EKEvent
        print("\(e?.title ?? "Kein event") wird übertragen")
        self.event = event
    }
    
}
