//
//  EditTMEventViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 25.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import RealmSwift


protocol EditEventDelegate {
    func eventEdited()
}

protocol AddEventDelegate {
    func eventAdded()
}



class EditTMEventViewController: UIViewController {
    
    
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    var tmEvent = TMEvent()
    
    var editEventDelegate: EditEventDelegate?
    var addEventDelegate: AddEventDelegate?
    var isAddingEvent = false
    var selectedDate: Date?
    
    var realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.timeme.realm")!
        directory = directory.appendingPathComponent("trackedevents.realm")
        print("AbsolutPath: " + directory.absoluteString)
        Realm.Configuration.defaultConfiguration.fileURL = directory
        
        realm = try! Realm()
            
        if isAddingEvent {
            
            navTitle.title = NSLocalizedString("add", comment: "")
            
            titleView.isHidden = false
            titleViewHeightConstraint.constant = 88
            viewHeightConstraint.constant = 790
            
            startTimePicker.datePickerMode = .dateAndTime
            endTimePicker.datePickerMode = .dateAndTime
        } else {
            
            navTitle.title = NSLocalizedString("edit", comment: "")
            
            titleView.isHidden = true
            titleViewHeightConstraint.constant = 0
            viewHeightConstraint.constant = 700
            
            startTimePicker.datePickerMode = .time
            endTimePicker.datePickerMode = .time
        }
        
        startTimePicker.addTarget(self, action: #selector(startDateChanged), for: .allEvents)
        startTimePicker.date = selectedDate ?? tmEvent.startDate
        startTimePicker.maximumDate = nil
        endTimePicker.date = selectedDate ?? tmEvent.endDate
        endTimePicker.minimumDate = selectedDate ?? tmEvent.startDate
    }
    
    
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        if isAddingEvent {
            
            if titleTextField.text! != "" {
                
                addEvent()
                dismissView()
            } else {
                
                titleTextField.layer.borderColor = UIColor.red.cgColor
                titleTextField.layer.borderWidth = 1
                titleTextField.layer.cornerRadius = 5
                titleTextField.attributedPlaceholder = NSAttributedString(string: titleTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
                
                scrollView.setContentOffset(CGPoint.zero, animated: true)
            }
            
        } else {
            
            editEvent()
            dismissView()
        }
    }
    
    
    
    func addEvent() {
        
        tmEvent.title = titleTextField.text!
        
        tmEvent.eventStartDate = startTimePicker.date
        tmEvent.eventEndDate = endTimePicker.date
        
        tmEvent.startDate = startTimePicker.date
        tmEvent.endDate = endTimePicker.date
        
        tmEvent.startDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startTimePicker.date)!
        tmEvent.endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endTimePicker.date)!
        
        tmEvent.status = .finishedTracking
        
        try! realm.write {
            realm.add(tmEvent)
        }
        
        addEventDelegate?.eventAdded()
    }
    
    
    
    func editEvent() {
        
        try! realm.write {
            
            tmEvent.startDate = startTimePicker.date
            tmEvent.endDate = endTimePicker.date
        }
        
        editEventDelegate?.eventEdited()
    }
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        dismissView()
    }
    
    
    
    func dismissView() {
        
//        if let eventViewController = editEventDelegate as? EventViewController {
//            self.splitViewController?.showDetailViewController(eventViewController, sender: nil)
//            self.navigationController?.
//        }
//        self.splitViewController?.navigationController?.popToRootViewController(animated: true)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func startDateChanged() {
        
        endTimePicker.minimumDate = startTimePicker.date
    }
}
