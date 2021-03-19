//
//  IntroViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 29.05.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import EventKit
import Contacts
import UserNotifications



protocol IntroViewControllerDelegate {
    func introEnded(skipped: Bool)
}


class IntroViewController: UIViewController {
    
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var buttonSpaceView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    let eventStore = EKEventStore()
    let contactStore = CNContactStore()
    let notificationCenter = UNUserNotificationCenter.current()
    
    var calendarAskForAccess = false
    var contactStoreAskForAccess = false
    var notificationAskForAccess = false
    
    let demoDays = 60
    
    var delegate : IntroViewControllerDelegate?
    
    var labelTexts = [String]()
    
    var labelIndicator = 0
    let nextStep = NSLocalizedString("next", comment: "next")
    let allowAccess = NSLocalizedString("allow access", comment: "allow access")
    let startNow = NSLocalizedString("start now", comment: "start now")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTexts = [NSLocalizedString("intro label 1", comment: "intro text"),
                      NSLocalizedString("intro label 2", comment: "intro text"),
                      NSLocalizedString("intro label 3", comment: "start now"),
                      NSLocalizedString("intro label 4", comment: "start now"),
                        /*Ü"Bei mehreren Einzelterminen ordnet time:me die Termine dem jeweiligen Kunden zu, sodass Du schnell und einfach siehst, wie lange Du bei einem Kunde warst.",*/
                      NSLocalizedString("intro label 5", comment: "start now"),
                      /*"In den Einstellungen kannst Du festlegen auf welche Stufen time:me deine erfassten Zeiten aufrunden soll!",*/
                      NSLocalizedString("intro label 6.1", comment: "start now") + "\(demoDays)" + NSLocalizedString("intro label 6.2", comment: "start now")
                     ]
        
        labelIndicator = 0
        loadEvent()
    }
    
    
    
    @IBAction func next(_ sender: UIButton) {
        
        labelIndicator += 1
        loadEvent()
    }
    
    
    
    @IBAction func back(_ sender: UIButton) {
        
        labelIndicator -= 1
        loadEvent()
    }
    
    
    
    func loadEvent() {
        print("LabelIndikator: \(labelIndicator)")
        switch labelIndicator {
            
        case 0:
            print("case 0 exec")
            textLabel.text = labelTexts[labelIndicator]
            backButton.isHidden = true
            buttonSpaceView.isHidden = true
            self.nextButton.setTitle(self.nextStep, for: .normal)
            
            
        case 1:
            print("case 1 exec")
            textLabel.text = labelTexts[labelIndicator]
            backButton.isHidden = false
            buttonSpaceView.isHidden = false
            
            if EKEventStore.authorizationStatus(for: .event) == .notDetermined {
                
                print("eventStore is not determined")
                self.nextButton.setTitle(self.allowAccess, for: .normal)
            } else {
                
                print("eventStore is determined")
                self.nextButton.setTitle(self.nextStep, for: .normal)
            }
            
            
        case 2:
            print("case 2 exec")
            if calendarAskForAccess {
                print("ask for calendar is true")
                DispatchQueue.main.async {
                    self.textLabel.text = self.labelTexts[self.labelIndicator]
                    self.nextButton.setTitle(self.nextStep, for: .normal)
                }
            } else {
                print("ask for calendar is false")
                self.getCalendarAccess()
            }
            
            
            
        case 3:
            print("case 3 exec")
            DispatchQueue.main.async {
                self.textLabel.text = self.labelTexts[self.labelIndicator]
            }
            
            notificationCenter.getNotificationSettings { (settings) in
            
                if settings.authorizationStatus == .notDetermined {
                    print("notifications is not determined")
                    DispatchQueue.main.async {
                        self.nextButton.setTitle(self.allowAccess, for: .normal)
                    }
                } else {
                    print("notifications is determined")
                    DispatchQueue.main.async {
                        self.nextButton.setTitle(self.nextStep, for: .normal)
                    }
                }
            }
            
            
            
        case 4:
            print("case 4 exec")
            if notificationAskForAccess {
                print("ask for notifications is true")
                DispatchQueue.main.async {
                    self.textLabel.text = self.labelTexts[self.labelIndicator]
                    self.nextButton.setTitle(self.nextStep, for: .normal)
                }
            } else {
                print("ask for notifications is false")
                getNotificationsAccess()
            }
            
        case 5:
            print("case 5 exec")
            DispatchQueue.main.async {
                self.textLabel.text = self.labelTexts[self.labelIndicator]
                self.nextButton.setTitle(self.startNow, for: .normal)
            }
            
        case 6:
            print("case 6 exec")
            self.delegate?.introEnded(skipped: false)
            dismiss(animated: true)
            
        default:
            fatalError()
        }
    }
    
    
    
    @IBAction func skip(_ sender: UIButton) {
        
        self.delegate!.introEnded(skipped: true)
        dismiss(animated: true)
    }
    
    
    
    func getCalendarAccess() {
        print("Asked for cal access")
        eventStore.requestAccess(to: .event) { (haveAccess, error) in

            self.calendarAskForAccess = true
            self.loadEvent()
        }
    }



    func getContactsAccess() {
        print("Asked for con access")
        contactStore.requestAccess(for: .contacts) { (haveAccess, error) in

            self.contactStoreAskForAccess = true
            self.loadEvent()
        }
    }



    func getNotificationsAccess() {
        print("Asked for not access")
        self.notificationCenter.requestAuthorization(options: [.alert, .badge, .carPlay, .sound], completionHandler: { (haveAccess, error) in

            self.notificationAskForAccess = true
            self.loadEvent()
        })
    }

    
    
}
