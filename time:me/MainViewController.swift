//
//  ViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 28.05.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import EventKit
import Contacts
import UserNotifications
import RealmSwift
import ChameleonFramework
import StoreKit
import MessageUI



protocol MainViewControllerDelegate: class {
    func eventChanged(event: Any?)
}



class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, UITableViewDelegate, UITableViewDataSource, DatePickerDelegate, IntroViewControllerDelegate, SelectCalendarsDelegate, EventViewDelegate, AddEventDelegate, BuyViewDelegate, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateButton: UIBarButtonItem!
    @IBOutlet weak var buyToolbarHeigth: NSLayoutConstraint!
    @IBOutlet weak var buyToolbar: UIToolbar!
    @IBOutlet weak var buyButton: UIBarButtonItem!
    
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    var currentDate = Date()
    var eventStore = EKEventStore()
    var contactStore = CNContactStore()
    var notificationCenter = UNUserNotificationCenter.current()
    
    weak var delegate: MainViewControllerDelegate?
    
    let defaults = UserDefaults.init(suiteName: "group.timeme.defaults")!
    let appLaunchedBefore = "AppLaunchedBefore"
    let firstLaunchingDate = "firstLaunchingDate"
    
    let calenderAccessNecessaryTitle = NSLocalizedString("calendar access necessary title", comment: "")
    let calenderAccessNecessaryDeclaration = NSLocalizedString("calendar access necessary declaration", comment: "")
    let settings = NSLocalizedString("settings", comment: "")
    let cancel = NSLocalizedString("cancel", comment: "")
    let okay = NSLocalizedString("okay", comment: "")
    
    let selectedCalKey = "selectedCalendars"
    let eventCellIdentifier = "eventCell"
    
    let productID = "com.timeme.timeme.timeme_plus"
    let demoDays = 60
    
    let dateFormatTime = "HH:mm"
    let dateFormatDate = "dd.MM.YY"
    
    var timer = Timer()
    
    var selectedDate = Date()
    var selectedEvent: Any?
    var selectedEventIndexPath: IndexPath?
    var calendars = [EKCalendar]()
    var ekEvents = [EKEvent]()
    var tmEvents: Results<TMEvent>?
    var events = [Any]()
    
    var realm = try! Realm()
    var realmToken: NotificationToken?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.timeme.realm")!
        directory = directory.appendingPathComponent("trackedevents.realm")
        Realm.Configuration.defaultConfiguration.fileURL = directory
        
        realm = try! Realm()
        
        realmToken = realm.observe({ (notification, realm) in
            
            self.reloadUI()
        })
        
        navigationController?.navigationBar.tintColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: eventCellIdentifier)
        tableView.rowHeight = 70
        
        setDateLabel(with: selectedDate)
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.timerUpdateEvents), userInfo: nil, repeats: true)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        SettingsBundleHelper().setVersionAndBuildNumber()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !defaults.bool(forKey: appLaunchedBefore) {
            
            defaults.set(Date(), forKey: firstLaunchingDate)
            print("APP DID NOT LAUNCH BEFORE!!!")
            performSegue(withIdentifier: "goToIntro", sender: self)
        } else {
            
            checkCalendarAccessStatus(isNeccessary: true)
        }
        
        checkBuyStatus()
        
        reloadUI()
        print("prepareEvents und reloadTableView ausgeführt")
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    func reloadUI() {
        
        prepareEvents()
        tableView.reloadData()
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            print("EVENTS: \(events.count)")
            print("inPathRow: \(selectedEventIndexPath?.row ?? 0)")
            let line = (selectedEventIndexPath?.row ?? 0) + 1
            print("Line: \(line)")
            if selectedEventIndexPath?.row ?? 0 < events.count {
                
                selectedEvent = events[selectedEventIndexPath?.row ?? 0]
                tableView.selectRow(at: selectedEventIndexPath, animated: true, scrollPosition: .top)
            } else if !events.isEmpty {
                
                selectedEventIndexPath = IndexPath(row: 0, section: 0)
                selectedEvent = events[selectedEventIndexPath?.row ?? 0]
                tableView.selectRow(at: selectedEventIndexPath, animated: true, scrollPosition: .top)
            } else {
                
                selectedEvent = nil
            }
        }
    }
    
    
    
    @objc func timerUpdateEvents() {
        reloadUI()
    }
    
    
    
    func checkCalendarAccessStatus(isNeccessary: Bool) {
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
            
        case .authorized:
            prepareEvents()
            
            if defaults.array(forKey: selectedCalKey) == nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToSelectCalendars", sender: self)
                }
            }
            
        case .notDetermined:
            eventStore.requestAccess(to: .event) { (haveAccess, error) in
                
                if haveAccess {
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goToSelectCalendars", sender: self)
                    }
                }
            }
            
        case .restricted, .denied:
            grantCalendarAccessAlert()
            
        default:
            break
        }
    }
    
    
    
    func grantCalendarAccessAlert() {
        
        let alert = UIAlertController(title: calenderAccessNecessaryTitle, message: calenderAccessNecessaryDeclaration, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: self.okay, style: .default) { (action) in
            
            self.performSegue(withIdentifier: "goToNoCalendarAccess", sender: self)
        }
        alert.addAction(okay)
        
        let settings = UIAlertAction(title: self.settings, style: .default) { (action) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alert.addAction(settings)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func checkNotificationsAccessStatus(isNeccessary: Bool) {
        
        notificationCenter.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .notDetermined {
                
                self.notificationCenter.requestAuthorization(options: [.alert, .badge, .carPlay, .sound], completionHandler: { (haveAccess, error) in })
            } else if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                
                self.setNotificationsForEvents(until: Calendar.current.date(byAdding: .month, value: 1, to: Date())!, nMinBeforeEvent: SettingsBundleHelper().getNotificationTime())
            }
        }
    }
    
    
    
    @IBAction func pickDate(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToPickDate", sender: self)
    }
    
    
    
    @IBAction func setTodaysDate(_ sender: UIBarButtonItem) {
        
        selectedDate = Date()
        setDateLabel(with: Date())
        
        reloadUI()
        delegate?.eventChanged(event: selectedEvent)
    }
    
    
    
    @IBAction func chooseCalendars(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToSelectCalendars", sender: self)
    }
    
    
    
    //MARK: - TableView DataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: eventCellIdentifier, for: indexPath) as! EventCell
        
        if let ekEvent = events[indexPath.row] as? EKEvent {
            cell.title.text = ekEvent.title
            
            
            var subtext = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle  =  Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: ekEvent.startDate) == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: ekEvent.endDate) ? .none : .short
            
            subtext = "\(dateFormatter.string(from: ekEvent.startDate)) - \(dateFormatter.string(from: ekEvent.endDate))"
            cell.subtitle.text = subtext
            
            cell.timeLabel.text = ""
            
            cell.indicator.backgroundColor = UIColor(cgColor: ekEvent.calendar.cgColor)
            cell.indicator.layer.cornerRadius = cell.indicator.frame.size.width / 2
            cell.indicator.clipsToBounds = true
            
        } else if let tmEvent = events[indexPath.row] as? TMEvent {
            cell.title.text = tmEvent.title
            
            var subtext = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle  =  Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tmEvent.startDate) == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tmEvent.endDate) ? .none : .short
            
            subtext = "\(dateFormatter.string(from: tmEvent.startDate)) - \(dateFormatter.string(from: tmEvent.endDate))"
            cell.subtitle.text = subtext
            
            let endDate = tmEvent.startDate == tmEvent.endDate ? Date() : tmEvent.endDate
            
            let hours = endDate.hours(from: tmEvent.startDate)
            let minutes = (endDate.minutes(from: tmEvent.startDate) % 60)
            
            cell.timeLabel.text = hours == 0 ? "\(minutes) min" : "\(hours) h \(minutes) min"
            
            cell.indicator.backgroundColor = UIColor(hexString: tmEvent.calendarColorHexValue)
            cell.indicator.layer.cornerRadius = cell.indicator.frame.size.width / 2
            cell.indicator.clipsToBounds = true
            
        } else {fatalError()}
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedEventIndexPath = indexPath
        
        selectedEvent = events[indexPath.row]
        delegate?.eventChanged(event: selectedEvent)
        
        if let eventViewController = delegate as? EventViewController, let navController = eventViewController.navigationController {
            splitViewController?.showDetailViewController(navController, sender: nil)
        }
    }
    
    
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "goToPickDate" {
            
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
            
            let destinationVC = segue.destination as! DatePickerViewController
            destinationVC.delegate = self
            destinationVC.startDate = selectedDate
        }
        
        if segue.identifier == "goToIntro" {
            
            let destinationVC = segue.destination as! IntroViewController
            destinationVC.delegate = self
        }
        
        if segue.identifier == "goToSelectCalendars" {
            
            let destinationVC = segue.destination as! SelectCalendarsViewController
            destinationVC.delegate = self
        }
        
        if segue.identifier == "goToEvent" {
            
            let destinationVC = segue.destination as! EventViewController
            
            destinationVC.delegate = self
            destinationVC.event = selectedEvent
        }
        
        if segue.identifier == "goToAddEvent" {
            
            let navVC = segue.destination as! UINavigationController
            let destinationVC = navVC.topViewController as! EditTMEventViewController
            
            destinationVC.addEventDelegate = self
            destinationVC.isAddingEvent = true
            destinationVC.selectedDate = selectedDate
        }
        
        if segue.identifier == "goToBuyView" {
            
            let destinationVC = segue.destination as! BuyViewController
            
            destinationVC.delegate = self
            destinationVC.demoDaysLeft = demoDays - Date().days(from: defaults.object(forKey: firstLaunchingDate) as! Date)
        }
    }
    
    
    
    //MARK: - DatePickerDelegate function
    func pickedDate(date: Date) {
        
        selectedDate = date
        setDateLabel(with: date)
        
        reloadUI()
        delegate?.eventChanged(event: selectedEvent)
    }
    
    
    
    //MARK: - IntroViewControllerDelegate function; flags that the app has been launched before
    func introEnded(skipped: Bool) {
        
        defaults.set(true, forKey: appLaunchedBefore)
        
        if skipped {
            
            checkCalendarAccessStatus(isNeccessary: true)
            checkNotificationsAccessStatus(isNeccessary: false)
        } else {
            
            performSegue(withIdentifier: "goToSelectCalendars", sender: self)
        }
    }
    
    
    
    //MARK: - SelectCalendarsDelegate function
    func calendarsSelected() {
        
        reloadUI()
        delegate?.eventChanged(event: selectedEvent)
        
        setNotificationsForEvents(until: Calendar.current.date(byAdding: .month, value: 1, to: Date())!, nMinBeforeEvent: SettingsBundleHelper().getNotificationTime())
    }
    
    
    
    //MARK: - EventViewDelegate function
    func eventViewWasDismissed() {
        
        tableView.deselectRow(at: selectedEventIndexPath!, animated: true)
        
        reloadUI()
        print("EventViewControllerDelegate function wurde ausgeführt")
    }
    
    
    
    //MARK: - EventAddedDelegate function
    func eventAdded() {
        
        reloadUI()
    }
    
    
    
    //MARK: - BuyViewDelegate function
    func didBuy(_ productID: String) {
        
        defaults.set(true, forKey: productID)
        checkBuyStatus()
        
        rateThisApp()
    }
    
    
    
    //MARK: - MailComposeControllerDelegate function
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
        if result == .sent {
            
            let alert = UIAlertController(title: NSLocalizedString("thank you", comment: ""), message: NSLocalizedString("thank you for comment", comment: ""), preferredStyle: .alert)
            
            alert.addAction( UIAlertAction(title: NSLocalizedString("okay", comment: ""), style: .default))
            
            present(alert, animated: true)
        }
    }
    
    
    
    //MARK: - Prepare the Events from Calendar and Realm Storage
    func prepareEvents() {
        
        getEKEvents()
        getTMEvents()
        deleteEventDuplicates()
        combineEventsInArray()
    }
    
    
    
    func getEKEvents() {
        
        calendars.removeAll()
        ekEvents.removeAll()
        
        if let selectedCalendars = defaults.array(forKey: selectedCalKey) as? [String] {
            
            for id in selectedCalendars {
                
                if let calendar = eventStore.calendar(withIdentifier: id) {
                    calendars.append(calendar)
                }
            }
        }
        
        if let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: selectedDate), let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) {
            if !calendars.isEmpty {
                
                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                ekEvents = eventStore.events(matching: predicate)
            }
        }
    }
    
    
    
    func getTMEvents() {
        
        tmEvents = realm.objects(TMEvent.self).filter("%@ >= startDay AND %@ <= endDay", selectedDate, selectedDate).sorted(byKeyPath: "eventStartDate")
    }
    
    
    
    //Compares tmEvents List and Events List and removes the ekEvent from Events if it already exists as tmEvent
    func deleteEventDuplicates() {
        
        for tmEvent in tmEvents! {
            
            var position = 0
            
            for ekEvent in ekEvents {
                
                if /*tmEvent.calendarItemExternalIdentifier == ekEvent.calendarItemExternalIdentifier*/ tmEvent.title == ekEvent.title && tmEvent.eventStartDate == ekEvent.startDate && tmEvent.eventEndDate == ekEvent.endDate {
                    ekEvents.remove(at: position)
                }
                
                position += 1
            }
        }
    }
    
    
    
    func combineEventsInArray() {
        
        events.removeAll()
        
        for ekEvent in ekEvents {
            events.append(ekEvent)
        }

        for tmEvent in tmEvents! {
            events.append(tmEvent)
        }
        
//        if !ekEvents.isEmpty {
//
//            var ekEventsCopy = [EKEvent]()
//
//            for ekEvent in ekEvents {
//                ekEventsCopy.append(ekEvent)
//            }
//
//            for tmEvent in tmEvents {
//
//                var ekEvPosition = 0
//
//                while tmEvent.eventStartDate > ekEventsCopy[ekEvPosition].startDate {
//
//                    events.append(ekEventsCopy[ekEvPosition])
//                    ekEventsCopy.remove(at: ekEvPosition)
//
//                    ekEvPosition += 1
//                }
//
//                events.append(tmEvent)
//            }
//
//            if !ekEventsCopy.isEmpty {
//
//                for ekEvent in ekEventsCopy {
//
//                    events.append(ekEvent)
//                }
//            }
//        } else {print("ekEvents is Empty")}
    }
    
    
    
    //MARK: - Set DateLabel
    func setDateLabel(with date: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle  = .medium
        dateButton.title = dateFormatter.string(from: date)
    }
    
    
    
    //MARK: - Add Event Manually
    @IBAction func addEvent(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToAddEvent", sender: self)
    }
    
    
    
    //MARK: - Set Notifications
    func setNotificationsForEvents(until endDate: Date, nMinBeforeEvent: Int) {
        
        var ekEvents = [EKEvent]()
        
        //Get all selected Calendars
        if let selectedCalendars = defaults.array(forKey: selectedCalKey) as? [String] {
            
            for id in selectedCalendars {
                
                if let calendar = eventStore.calendar(withIdentifier: id) {
                    calendars.append(calendar)
                }
            }
        }
        
        //Get all EKEvents within a month from now
        let startDate = Date()
        if !calendars.isEmpty {
            
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
            ekEvents = eventStore.events(matching: predicate)
        }
        
        //Creating the notifications
        var notifications = [Notification]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        for ekEvent in ekEvents {
            let tenMinBeforeStartDate = Calendar.current.date(byAdding: .minute, value: (-1 * nMinBeforeEvent), to: ekEvent.startDate)!
            
            var datetime: DateComponents!
            
            datetime = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tenMinBeforeStartDate)
            
            dateFormatter.dateStyle  =  Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: ekEvent.startDate) == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: ekEvent.endDate) ? .none : .short
            
            let notification = Notification(id: "\(String(describing: ekEvent.startDate))\(String(describing: ekEvent.title))\(String(describing: ekEvent.endDate))", notificationType: .eventNotification, title: ekEvent.title, subtitle: nil, body: "\(dateFormatter.string(from: ekEvent.startDate)) - \(dateFormatter.string(from: ekEvent.endDate))", datetime: datetime)
            
            notifications.append(notification)
        }
        
        //Set notifications
        let notificationManager = LocalNotificationManager()
        notificationManager.cancelAllNotifications()
        notificationManager.schedule(notifications: notifications)
    }
    
    
    
    //MARK: - Sell functions
    @IBAction func buyButtonClicked(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToBuyView", sender: self)
    }
    
    
    
    func checkBuyStatus() {
        
        if defaults.bool(forKey: productID) {
            
            buyToolbar.isHidden = true
            tableviewBottomConstraint.constant = 0
        } else {
            
            tableviewBottomConstraint.constant = 84
            buyButton.title = NSLocalizedString("buy toolbar text 1", comment: "") + "\(demoDays - (Date().days(from: defaults.object(forKey: firstLaunchingDate) as! Date)))" + NSLocalizedString("buy toolbar text 2", comment: "")
            buyToolbar.isHidden = false
            
            if Date().days(from: defaults.object(forKey: firstLaunchingDate) as! Date) >= demoDays {
                
                performSegue(withIdentifier: "goToBuyView", sender: self)
            }
        }
    }
    
    
    
    //MARK: - Rate app
    func rateThisApp() {
        
        let alert = UIAlertController(title: NSLocalizedString("enjoy time:me", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let yes = UIAlertAction(title: NSLocalizedString("absolutely", comment: ""), style: .default) { (action) in
            
            SKStoreReviewController.requestReview()
        }
        alert.addAction(yes)
        
        let no = UIAlertAction(title: NSLocalizedString("not really", comment: ""), style: .default) { (action) in
            
            let messageAlert = UIAlertController(title: NSLocalizedString("sorry to hear that", comment: ""), message: NSLocalizedString("contact developer", comment: ""), preferredStyle: .alert)
            
            messageAlert.addAction( UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil))
            
            let writeMessage = UIAlertAction(title: NSLocalizedString("contact us", comment: ""), style: .default, handler: { (action) in
                
                if MFMailComposeViewController.canSendMail() {
                    
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["support@timeme.eu"])
                    mail.setSubject(NSLocalizedString("rate email subject", comment: ""))
                    
                    self.present(mail, animated: true)
                    
                } else {
                    
                    let notPossibleAlert = UIAlertController(title: NSLocalizedString("error not possible", comment: ""), message: nil, preferredStyle: .alert)
                    
                    notPossibleAlert.addAction( UIAlertAction(title: NSLocalizedString("okay", comment: ""), style: .default, handler: nil))
                    
                    self.present(notPossibleAlert, animated: true)
                }
            })
            messageAlert.addAction(writeMessage)
            
            self.present(messageAlert, animated: true)
        }
        alert.addAction(no)
        
        present(alert, animated: true)
        print("alert presented")
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        rateThisApp()
//    }
}

