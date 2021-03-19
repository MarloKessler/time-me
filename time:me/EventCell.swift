//
//  EventCell.swift
//  time:me
//
//  Created by Marlo Kessler on 07.06.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    
    @IBOutlet weak var indicator: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        indicator.layer.cornerRadius = indicator.frame.size.width / 2
//        indicator.clipsToBounds = true
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
