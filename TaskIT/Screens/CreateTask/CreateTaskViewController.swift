//
//  CreateTaskViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 05/05/22.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseFirestoreSwift


class CreateTaskViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var taskTitleField: UITextView!
    
    @IBOutlet weak var taskDescField: UITextView!
    
    weak var databaseController: DatabaseProtocol?
    
    weak var authController: Auth?
    weak var database: Firestore?
    weak var checklistsRef: CollectionReference?
    weak var currentUser: FirebaseAuth.User?
    
    var myReminderDate: Date?
    
    var priorityLabel: PriorityLabel = .low
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        taskTitleField.delegate = self
        taskDescField.delegate = self
        // Showing today's date at the top of the task screen to the user
        let date = Date()
        let format = date.getFormattedDate(format: "MMM d, yyyy")
        self.navigationController?.navigationBar.topItem?.title = format
        // Do any additional setup after loading the view.
        
        
    }
    
    
    @IBAction func labelBtnClicked(_ sender: Any) {
        // This will show user the label alert , to choose their needed priority
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
        
        // Showing the alert
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    @IBAction func testBtnClicked(_ sender: Any) {
        // When user clicks the done button, task gets saved in core data and other actions happen accordingly
        
        if taskTitleField.text == "Task Title" || taskDescField.text == "Task Description" {
            displayMessage(title: "Invalid", message: "Title or Description cannot be empty!")
            return
        }
        
        print(taskTitleField.text)
        let myTask = databaseController?.addTask(taskTitle: taskTitleField.text!, taskDescription: taskDescField.text!, isChecklist: false, checklistItems: NSSet(), priorityLabel: self.priorityLabel)
        let firebaseTask = addTaskToFirebase(taskTitle: taskTitleField.text!, taskDescription: taskDescField.text!, isChecklist: false, checklistItems: [])
        print(myTask)
        
        // Create a notification content object
        
        // SettingNotifications
        if self.myReminderDate != nil {
            let notificationContent = UNMutableNotificationContent()
            // Create its details
            notificationContent.title = "TaskIT"
            notificationContent.subtitle = taskTitleField.text!
            notificationContent.body = taskDescField.text!
            notificationContent.sound = .defaultRingtone
            
            let timeInterval = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents(
                    [.day, .month, .year, .hour, .minute],
                    from: self.myReminderDate!),
                repeats: false)
            
            //         let timeInterval = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: "FIT3178-TaskIT",
                                                content: notificationContent, trigger: timeInterval)
            
            UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
            print("Notification scheduled.")
            
        }
        // TODO: Jump Back to main view controller
        self.tabBarController?.selectedIndex = 0
        print("Completed !")
    }
    
    
    func addTaskToFirebase(taskTitle: String, taskDescription: String, isChecklist: Bool, checklistItems: [ChecklistItem]) -> TaskItem{
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
    
    
    func barButtonItemClicked() {
        // TODO: Add Checks for field, to verify they are not empty
        //        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        //        databaseController = appDelegate?.databaseController
        //        print(taskTitleField.text)
        //        let myTask = databaseController?.addTask(taskTitle: taskTitleField.text!, taskDescription: taskDescField.text!, isChecklist: false, checklistItems: NSSet())
        //        print(myTask)
        //        // TODO: Jump Back to main view controller
        //        self.dismiss(animated: true)
        //        print("Completed !")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewControllerB = segue.destination as? ReminderViewController {
            // This callback method get's called when user returns back from reminder view controller and stores the date in a variable to be accessed later
            viewControllerB.callback = { message in

                print(message)
                self.myReminderDate = message
                
            }
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // This method basically handles unhighliting of the text field, after getting selected
        if textView.textColor == UIColor.systemGray4 {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        if textView.textColor == UIColor.systemGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // This method get's triggered as soon as user stops typing, and highlighting the text field again if it is empty
        if textView.text.isEmpty {
            if textView.restorationIdentifier == "textDescription" {
                textView.text = "Task Description"
                textView.textColor = UIColor.systemGray
            }
            else {
                textView.text = "Task Title"
                textView.textColor = UIColor.systemGray4
            }
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


extension Date {
    // Extension method to perform date formate from a string
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

