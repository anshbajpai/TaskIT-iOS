//
//  CoreDataController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//

import UIKit
import CoreData


class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {

    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allTasksFetchedResultsController: NSFetchedResultsController<TaskUnit>?


    
    override init() {
        persistentContainer = NSPersistentContainer(name: "TaskIT-Model")
        persistentContainer.loadPersistentStores() { (description, error ) in
         if let error = error {
         fatalError("Failed to load Core Data Stack with error: \(error)")
         }
        }
     super.init()
    }
    
    func cleanup() {
     if persistentContainer.viewContext.hasChanges {
     do {
     try persistentContainer.viewContext.save()
     } catch {
     fatalError("Failed to save changes to Core Data with error: \(error)")
     }
     }
    }
    
    func addTask(taskTitle: String, taskDescription: String, isChecklist: Bool, checklistItems: NSSet, priorityLabel: PriorityLabel) -> TaskUnit {
        let taskItem = NSEntityDescription.insertNewObject(forEntityName: "TaskUnit", into: persistentContainer.viewContext) as! TaskUnit
        taskItem.taskTitle = taskTitle
        taskItem.taskDescription = taskDescription
        taskItem.isChecklist = isChecklist
        taskItem.myPriorityLabel = priorityLabel
        if isChecklist {
            taskItem.addToChecklistItems(checklistItems)
        }
        
        return taskItem
     }
    
    func addChecklist(checklistDesc: String, isChecklist: Bool) -> ChecklistUnit {
        let checklistItem = NSEntityDescription.insertNewObject(forEntityName: "ChecklistUnit", into: persistentContainer.viewContext) as! ChecklistUnit
        
        checklistItem.checklistDescription = checklistDesc
        checklistItem.isChecklist = isChecklist
        
        return checklistItem
    }
    
    func addChecklistToTeam(checklistItem: ChecklistUnit, taskItem: TaskUnit) {
        taskItem.addToChecklistItems(checklistItem)
    }
    
    func removeChecklistToTeam(checklistItem: ChecklistUnit, taskItem: TaskUnit) {
        taskItem.removeFromChecklistItems(checklistItem)
    }
    
    // When a user logs out, this function destroys the whole persistent container and re - make it for creating a new batch
    func deleteAllTasks() {
        // Specify a batch to delete with a fetch request
        
        do {
            let storeContainer =
                persistentContainer.persistentStoreCoordinator

            // Delete each existing persistent store
            for store in storeContainer.persistentStores {
                try storeContainer.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            }

            // Re-create the persistent container
            persistentContainer = NSPersistentContainer(
                name: "TaskIT-Model" // the name of
                // a .xcdatamodeld file
            )

            // Calling loadPersistentStores will re-create the
            // persistent stores
            persistentContainer.loadPersistentStores {
                (store, error) in
                // Handle errors
            }
        }
        catch let error as NSError {
            // Error
        }
    }
    
    // Performs search operation in core data according to the predicate provided and returns the filtered result
    func searchAllTasks(searchQuery: String?) -> [TaskUnit] {
        // Code
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "taskTitle contains[c] '\(searchQuery ?? "")'")
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"TaskUnit")
        fetchRequest.predicate = predicate
        var allTasks:[TaskUnit] = []
        do {
            allTasks = try managedObjectContext.fetch(fetchRequest) as! [TaskUnit]
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
        
        return allTasks
    }
    
    func getAllTasks() -> [TaskUnit] {
        let allTasks = fetchAllTasks()
        
        return allTasks
    }
    
    // Delete checklist items from core data contoller
    func deleteAllChecklistItems() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ChecklistUnit")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            self.cleanup()
        } catch let error as NSError {
            // TODO: handle the error
        }
    }
    
    // Perform deletion of the task from core data
    func deleteTask(taskNote: TaskUnit) {
        persistentContainer.viewContext.delete(taskNote)
    }
    
    // Fetches all the tasks from the core data
    func fetchAllTasks() -> [TaskUnit] {

        if allTasksFetchedResultsController == nil {
            let request: NSFetchRequest<TaskUnit> = TaskUnit.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "taskTitle", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allTasksFetchedResultsController =
             NSFetchedResultsController<TaskUnit>(fetchRequest: request,
             managedObjectContext: persistentContainer.viewContext,
             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            allTasksFetchedResultsController?.delegate = self
            
            do {
             try allTasksFetchedResultsController?.performFetch()
            } catch {
             print("Fetch Request Failed: \(error)")
            }
        }

        if let tasks = allTasksFetchedResultsController?.fetchedObjects {
        return tasks
        }
        return [TaskUnit]()

    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .all {
            listener.onAllTasksChange(change: .update, allTaskNote: fetchAllTasks())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    // Grt' striggered when a change is observed in the controller
    
    func controllerDidChangeContent(_ controller:
      NSFetchedResultsController<NSFetchRequestResult>) {
      if controller == allTasksFetchedResultsController {
      listeners.invoke() { listener in
      if (listener.listenerType == .all) {
          listener.onAllTasksChange(change: .update,allTaskNote: fetchAllTasks())
      }
      }
      }

      
      
     }

    
    
}
