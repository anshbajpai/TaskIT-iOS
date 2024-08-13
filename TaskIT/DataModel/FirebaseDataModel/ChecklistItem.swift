//
//  ChecklistItem.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 12/05/22.
//

import UIKit

// Model ChecklistUnit Class for uploading data onto firebase
class ChecklistItem: NSObject, Codable {
    
    var id: String?
    var checklistDescription: String?
    var isChecked: Bool?
    
}
