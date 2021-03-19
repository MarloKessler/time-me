//
//  DatePickerController.swift
//  time:me
//
//  Created by Marlo Kessler on 28.05.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit



protocol DatePickerDelegate {
    func pickedDate(date: Date)
}



class DatePickerViewController: UIViewController {
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DatePickerDelegate?
    var startDate: Date?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let date = startDate {
            
            datePicker.date = date
        }
        
    }
    
    

    @IBAction func saveDate(_ sender: UIBarButtonItem) {
        
        if let delegate = delegate {
            delegate.pickedDate(date: datePicker.date)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
