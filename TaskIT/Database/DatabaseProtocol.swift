//
//  DatabaseProtocol.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//

import Foundation


// Types of database change
enum DatabaseChange {
 case add
 case remove
 case update
}

// Type of listener needed for this application
enum ListenerType {
 case task
 case all
}

protocol DatabaseListener: AnyObject {
 var listenerType: ListenerType {get set}
 func onTaskChange(change: DatabaseChange, taskNote: TaskUnit)
 func onAllTasksChange(change: DatabaseChange, allTaskNote: [TaskUnit])
}

// Defines method used in CoreDataController implementation
protocol DatabaseProtocol: AnyObject {
 func cleanup()

 func addListener(listener: DatabaseListener)
 func removeListener(listener: DatabaseListener)

func addTask(taskTitle: String, taskDescription: String, isChecklist: Bool, checklistItems: NSSet, priorityLabel: PriorityLabel) -> TaskUnit
 
func deleteTask(taskNote: TaskUnit)
    
func deleteAllTasks()
    
func searchAllTasks(searchQuery: String?) -> [TaskUnit]
    
func getAllTasks() -> [TaskUnit]
    
func deleteAllChecklistItems()
    
func addChecklist(checklistDesc: String, isChecklist: Bool) -> ChecklistUnit 
 
func addChecklistToTeam(checklistItem: ChecklistUnit, taskItem: TaskUnit)
    
func removeChecklistToTeam(checklistItem: ChecklistUnit, taskItem: TaskUnit)
    
}
