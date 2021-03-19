//
//  PopOverListViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 03.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import EventKit
import M13Checkbox



protocol SelectCalendarsDelegate {
    func calendarsSelected()
}



class SelectCalendarsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var popOverView: UIView!
    @IBOutlet weak var popOverViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var calendarTableViewHeightConstraint: NSLayoutConstraint!
    
    var delegate : SelectCalendarsDelegate?
    
    let defaults = UserDefaults.init(suiteName: "group.timeme.defaults")!
    
    let eventStore = EKEventStore()
    
    var calendars = [TMCalendar]()
    let selectedCalKey = "selectedCalendars"
    let cellIdentifier = "calendarCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popOverView.layer.cornerRadius = 10
        popOverView.layer.masksToBounds = true
        
        var savedCalendars = [String]()
        
        if let calList = defaults.array(forKey: selectedCalKey) as? [String] {
            
            savedCalendars = calList
        } else {
            
            savedCalendars.append("")
        }
        
        let allCalendars = eventStore.calendars(for: .event)
        
        for calendar in allCalendars {
            
            var isSelected = false
            
            for id in savedCalendars {
                
                if id == calendar.calendarIdentifier {
                    isSelected = true
                }
            }
            
            calendars.append(TMCalendar(isSelected: isSelected, calendar: calendar))
        }
        
        let calendarTableViewHeight: CGFloat = CGFloat(calendars.count * 44)
        let popOverHeight: CGFloat = (70 + calendarTableViewHeight + 55)
        
        if  popOverHeight >= 520 {
            
            calendarTableViewHeightConstraint.constant = 395
            popOverViewHeightConstraint.constant = 520
            calendarTableView.isScrollEnabled = true
        } else {
            
            calendarTableViewHeightConstraint.constant = calendarTableViewHeight
            popOverViewHeightConstraint.constant = popOverHeight
            calendarTableView.isScrollEnabled = false
        }
        
        calendarTableView.delegate = self
        calendarTableView.dataSource = self
        calendarTableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        calendarTableView.rowHeight = 40
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CalendarCell
        
        let calendar = calendars[indexPath.row]
        
        cell.calendarName.text = calendar.calendar.title
        cell.checkBox.secondaryTintColor = UIColor(cgColor: calendar.calendar.cgColor)
        cell.checkBox.tintColor = UIColor(cgColor: calendar.calendar.cgColor)
        cell.checkBox.stateChangeAnimation = .bounce(.fill)
        
        cell.checkBox.checkState = calendar.isSelected ? .checked : .unchecked
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        calendars[indexPath.row].isSelected = !calendars[indexPath.row].isSelected
        
        calendarTableView.reloadData()
    }
    
    
    
    @IBAction func selectCalendars(_ sender: UIButton) {
        
        var selectedCalendars = [String]()
        
        for calendar in calendars {
            
            if calendar.isSelected {
                print("\(calendar.calendar.title) is selected")
                
                selectedCalendars.append(calendar.calendar.calendarIdentifier)
            } else {print("\(calendar.calendar.title) is not selected")}
        }
        
        if selectedCalendars.isEmpty {
            selectedCalendars.append("")
        }
        print("Selected cals are: \(selectedCalendars)")
        
        defaults.set(selectedCalendars, forKey: selectedCalKey)
        
        delegate?.calendarsSelected()
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func tapOutside(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}
