//
//  TaskUnit+CoreDataProperties.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 19/05/22.
//
//

import Foundation
import CoreData


enum PriorityLabel: Int32 {
    case high = 0
    case medium = 1
    case low = 2
}


extension TaskUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskUnit> {
        return NSFetchRequest<TaskUnit>(entityName: "TaskUnit")
    }

    @NSManaged public var isChecklist: Bool
    @NSManaged public var taskDescription: String?
    @NSManaged public var taskTitle: String?
    @NSManaged public var priorityLabel: Int32
    @NSManaged public var checklistItems: NSSet?

}

// MARK: Generated accessors for checklistItems
extension TaskUnit {

    @objc(addChecklistItemsObject:)
    @NSManaged public func addToChecklistItems(_ value: ChecklistUnit)

    @objc(removeChecklistItemsObject:)
    @NSManaged public func removeFromChecklistItems(_ value: ChecklistUnit)

    @objc(addChecklistItems:)
    @NSManaged public func addToChecklistItems(_ values: NSSet)

    @objc(removeChecklistItems:)
    @NSManaged public func removeFromChecklistItems(_ values: NSSet)

}

extension TaskUnit : Identifiable {

}

extension TaskUnit {
    var myPriorityLabel: PriorityLabel {
        get {
            return PriorityLabel(rawValue: self.priorityLabel)!
        }
        
        set {
            self.priorityLabel = newValue.rawValue
        }
    }
}
