//
//  TMProject.swift
//  Tracker
//
//  Created by Marlo Kessler on 07.08.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import Foundation
import RealmSwift

class TMProject: Object {
    
    let classVersion = "1.0"
    
    var events = List<TMEvent>()
    
    var parentCategory = LinkingObjects(fromType: TMClient.self, property: "projects")
}
