//
//  ChecklistUnit+CoreDataProperties.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//
//

import Foundation
import CoreData


extension ChecklistUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistUnit> {
        return NSFetchRequest<ChecklistUnit>(entityName: "ChecklistUnit")
    }

    @NSManaged public var checklistDescription: String?
    @NSManaged public var isChecklist: Bool
    @NSManaged public var taskItem: TaskUnit?

}

extension ChecklistUnit : Identifiable {

}
