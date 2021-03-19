//
//  CalendarCell.swift
//  time:me
//
//  Created by Marlo Kessler on 04.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import M13Checkbox

class CalendarCell: UITableViewCell {

    
    @IBOutlet weak var calendarName: UILabel!
    @IBOutlet weak var checkBox: M13Checkbox!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
