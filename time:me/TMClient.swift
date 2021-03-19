//
//  TMClient.swift
//  time:me
//
//  Created by Marlo Kessler on 07.08.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import RealmSwift

class TMClient: Object {
    
    let classVersion = "1.0"
    
    var projects = List<TMProject>()
}
