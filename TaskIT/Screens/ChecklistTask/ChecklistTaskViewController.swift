//
//  ChecklistTaskViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ChecklistTaskViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CheckListTableViewCellDelegate, UITableViewDelegate {
    
    // This is the Checklist View controller, it basically gives user the ability to add checklist items to their task and edit them accordingly

    @IBOutlet weak var checklistDescField: CustomTextField!
    
    @IBOutlet weak var taskTitleField: UITextView!
    
    @IBOutlet weak var checklistTableView: UITableView!
    
    weak var databaseController: DatabaseProtocol?
    
    var priorityLabel: PriorityLabel = .medium

    var allTasks: [ChecklistItem] = []
    
    weak var authController: Auth?
    weak var database: Firestore?
    weak var checklistsRef: CollectionReference?
    weak var currentUser: FirebaseAuth.User?
    
    var myReminderDate: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // AallTasks here stores, the different checklist item created by the user
        allTasks = []
        let dummyChecklist1 = ChecklistItem()
        let dummyChecklist2 = ChecklistItem()
        let dummyChecklist3 = ChecklistItem()
        
        // Created three dummy checklist , to give user a basic idea of the user interface
        // They can obviously be deleted by swiping left
        dummyChecklist1.checklistDescription = "Buy milk from coles - 1L"
        dummyChecklist1.isChecked = false
        
        dummyChecklist2.checklistDescription = "Buy vegetables for dinner"
        dummyChecklist2.isChecked = false
        
        dummyChecklist3.checklistDescription = "Complete science homework"
        dummyChecklist3.isChecked = false
        allTasks.append(dummyChecklist1)
        allTasks.append(dummyChecklist2)
        allTasks.append(dummyChecklist3)
        
        authController = Auth.auth()
        database = Firestore.firestore()
        checklistDescField.delegate = self
        taskTitleField.delegate = self
        
        // Formatting the date and displaying it on the navigation title
        let date = Date()
        let format = date.getFormattedDate(format: "MMM d, yyyy")
        self.navigationController?.navigationBar.topItem?.title = format
        // Do any additinal setup after loading the view.
    }
    
    
    @IBAction func addChecklistBtnClicked(_ sender: Any) {
        // This method handles the addition of checklist items , after checking the basic validatiom
        if checklistDescField.hasText {
            let newChecklistItem = ChecklistItem()
            newChecklistItem.isChecked = false
            newChecklistItem.checklistDescription = checklistDescField.text
            allTasks.append(newChecklistItem)
            checklistDescField.text = ""
            checklistTableView.reloadData()
        }
    }
    
    
    @IBAction func reminderBtnClicked(_ sender: Any) {
        // Doesn;t need to be handled here
    }
    
    
    @IBAction func testBtnClicked(_ sender: Any) {
        
        // This method gets triggered after user clicks on done button and tasks needs to be saved

        // Validity checks
        if taskTitleField.text == "Task Title" {
            self.displayMessage(title: "Invalid", message: "Task Title cannot be empty!")
            return
        }
        
        if allTasks.isEmpty {
            self.displayMessage(title: "Invalid", message: "There needs to be atleast one checklist item!")
            return
        }
        
        var allChecklistItems: Set<ChecklistUnit> = []
        var allFirebaseChecklistItems: [ChecklistItem] = []
        
        // Storing all the tasks from allTasks array into ChecklistItem
        for task in self.allTasks {
            if task.checklistDescription != nil {
            guard let newChecklistItem = databaseController?.addChecklist(checklistDesc: task.checklistDescription!, isChecklist: task.isChecked!) else { return }
            allChecklistItems.insert(newChecklistItem)
            var newFirebaseChecklistItem = ChecklistItem()
            newFirebaseChecklistItem.checklistDescription = task.checklistDescription
            newFirebaseChecklistItem.isChecked = task.isChecked
            allFirebaseChecklistItems.append(newFirebaseChecklistItem)
        }
        }
        
        //Storing the task in core data
        let _ = databaseController?.addTask(taskTitle: taskTitleField.text!, taskDescription: "None", isChecklist: true, checklistItems: allChecklistItems as NSSet, priorityLabel: self.priorityLabel)
        
        // Storing the task in online database - Firebase
        let firebaseTask = addTaskToFirebase(taskTitle: taskTitleField.text!, taskDescription: "None", isChecklist: true, checklistItems: allFirebaseChecklistItems)
        
        // Setting up the notifications, if user has set up a date and time
        if self.myReminderDate != nil {
            let notificationContent = UNMutableNotificationContent()
            // Create its details
            notificationContent.title = "TaskIT"
            notificationContent.subtitle = taskTitleField.text!
            notificationContent.body = "Checklist Task Due!"
            notificationContent.sound = .defaultRingtone
            
            let timeInterval = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.day, .month, .year, .hour, .minute],
                    from: self.myReminderDate!),
                repeats: false)
            
            //         let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: "sadqoiuhhrhho",
                                                content: notificationContent, trigger: timeInterval)
            
            UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
            print("Notification scheduled.")
            
        }
        
        // Updating the tab index
        self.tabBarController?.selectedIndex = 0
//        let _ = databaseController?.addTask(taskTitle: taskTitleField.text!, taskDescription: "None", isChecklist: true, checklistItems: allChecklistItems as NSSet)
        
        
        
    }
    
    
    @IBAction func labelBtnClicked(_ sender: Any) {
        
        // Showing alert to the user, so that user can choose appropriate label priority
        
        let optionMenu = UIAlertController(title: "Choose Priority", message: "Each priority has different functionalities", preferredStyle: .actionSheet)
        
        let highPriority = UIAlertAction(title: "High Priority", style: .default){(action:UIAlertAction) in

            self.priorityLabel = .high
        }
        let mediumPriority = UIAlertAction(title: "Medium Priority", style: .default){(action:UIAlertAction) in
            
            self.priorityLabel = .medium
        }
        let lowPriority = UIAlertAction(title: "Low Priority", style: .default){(action:UIAlertAction) in
            self.priorityLabel = .low
            
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        
        optionMenu.addAction(highPriority)
        optionMenu.addAction(mediumPriority)
        optionMenu.addAction(lowPriority)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    func addTaskToFirebase(taskTitle: String, taskDescription: String, isChecklist: Bool, checklistItems: [ChecklistItem]) -> TaskItem{
        
        // Adding task to firebase, using auth id and parameters provided
        
        let task = TaskItem()
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription
        task.isChecklist = isChecklist
        task.checklistItems = checklistItems
        task.taskPriorityLabel = self.priorityLabel
        
        do {
//         if let taskRef = try tasksRef?.addDocument(from: task) {
//         task.id = taskRef.documentID
//         }
            let taskRef =  try database!.collection("users").document((authController?.currentUser!.uid)!).collection("task").addDocument(from: task)
        } catch {
         print("Failed to serialize hero")
        }
        
        return task
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? ReminderViewController {
            // This method is just responsible for handling the callback, after user sets a reminder date and comes back to the view controller
            viewControllerB.callback = { message in
                //Do what you want in here!
                print(message)
                self.myReminderDate = message
                
            }
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Updating checkfield color
        checklistDescField.change = true
        if textField.textColor == UIColor.systemGray4  {
            textField.text = nil
            textField.textColor = UIColor.black
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checklistDescField.change = false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Task Title" && textView.restorationIdentifier == "taskTitleIdentifier" {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.restorationIdentifier == "taskTitleIdentifier" {
                textView.text = "Task Title"
                textView.textColor = UIColor.systemGray3
            }
        }
    }
    
    func checkListTableViewCell(_ cell: ChecklistTableViewCell, didChangeCheckedState checked: Bool) {
        
        // getting cell index path, and storing it into a task variable to update the ui and maintain the sate of checklist in the array
        
        guard let indexPath = checklistTableView.indexPath(for: cell) else {
            return
        }
        let task = allTasks[indexPath.row]
        
        task.isChecked = checked
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Adding swipe ability to the checklist items, so they can be deleted and completed accordingly
        let action = UIContextualAction(style: .normal, title: "TaskIT"){ action, view, complete in
            
            let task = self.allTasks[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! ChecklistTableViewCell
            cell.set(checked: true)
            
            complete(true)
            print("TaskedIT")
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Handlind deletion
        if editingStyle == .delete {
            allTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChecklistTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Populating the checklist table view cellm with approipriate values and state
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkboxCell", for: indexPath) as! ChecklistTableViewCell
    
        cell.delegate = self
        let task = self.allTasks[indexPath.row]
        if task.checklistDescription != nil {
            cell.set(description: task.checklistDescription!, checked: task.isChecked!)
        }
        return cell
    }
}

class CustomTextField: UITextField{
   
    // Basically gets triggered, when a particular change occurs
    var change: Bool = false {
        didSet {
            textColor = change ? .black : .black
            backgroundColor = change ? .systemGray6 : .white
        }
    }
    
}
