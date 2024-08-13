//
//  TaskUnit+CoreDataProperties.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//
//

import Foundation
import CoreData


extension TaskUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskUnit> {
        return NSFetchRequest<TaskUnit>(entityName: "TaskUnit")
    }

    @NSManaged public var taskTitle: String?
    @NSManaged public var taskDescription: String?
    @NSManaged public var isChecklist: Bool
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
