//
//  NoCalendarAccessViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 04.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import EventKit

class NoCalendarAccessViewController: UIViewController {
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsButton.layer.borderColor = UIColor.white.cgColor
        settingsButton.layer.borderWidth = 2
        settingsButton.layer.cornerRadius = 5
        
    }
    
    
    
    @IBAction func settings(_ sender: UIButton) {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}
