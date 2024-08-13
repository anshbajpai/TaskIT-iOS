//
//  HomeViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 01/05/22.
//

import UIKit
import Hover
import Floaty
import Firebase
import FirebaseFirestoreSwift
import FirebaseFunctions
import FirebaseFunctionsSwift

class HomeViewController: UIViewController, DatabaseListener, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    

    

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // variable to store allTasks getting displayed in collection view
    var allTasks: [TaskUnit] = []
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    var firstSignUp: Bool = false
    
    // This variable controls, when sync with firebase operation should occur
    var shouldSync: Bool = true

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // This is a test tasks array, to populate the collection view initially
    let tasks: [TaskTest] = [
        TaskTest(taskTitle: "Title 1 Here"),
        TaskTest(taskTitle: "Title 2 Here", isChecked: true),
        TaskTest(taskTitle: "Title 3 Here", isChecked: true),
        TaskTest(taskTitle: "Title 4 Here"),
        TaskTest(taskTitle: "Title 5 Here",isChecked: true) ,
        TaskTest(taskTitle: "Title 6 Here"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize App Delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        

        // makes sure the keyboard dissapears when user taps outside the keyboard area
        hideKeyboardWhenTappedAround()

        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
//        let floatingButton = UIButton()
//        floatingButton.setTitle("+", for: .normal)
//        floatingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
//        //floatingButton.setImage(UIImage(named: "add-logo"), for: .normal)
//        floatingButton.contentMode = .center
//        floatingButton.backgroundColor = UIColor(red: 0.208, green: 0.424, blue: 0.976, alpha: 1.0)
//
//
//        floatingButton.layer.cornerRadius = 25
//
//        floatingButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
//        floatingButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        floatingButton.layer.shadowOpacity = 1.0
//        floatingButton.layer.shadowRadius = 5.0
//        floatingButton.layer.masksToBounds = false
//        floatingButton.layer.cornerRadius = 25.0
//        view.addSubview(floatingButton)
//        floatingButton.translatesAutoresizingMaskIntoConstraints = false
//
//        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
//
//        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor).isActive = true
//
//        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
//
//        floatingButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)


    }
    
    override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     // Adding Listener, so database changes can be observed
     databaseController?.addListener(listener: self)
}
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
        // Removing database from listener
     databaseController?.removeListener(listener: self)
    }

    
    @IBAction func settingsBtnClicked(_ sender: Any) {
        print("Clicked")
        // To view the settings page
        performSegue(withIdentifier: "settingsSegue", sender: nil)
    }
    
    
    private func syncWithFirebase(){
      // This function is just responsible for fetching the data from firebase and storing it on core data, to maintain the source -> so changes can be observed accordingly
            let firestoreDatabase = Firestore.firestore()
               
            let authController = Auth.auth()
        authController.addStateDidChangeListener { auth, user in
            print(auth)
        }
        firestoreDatabase.collection("users").document(authController.currentUser!.uid).collection("task").getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for change in querySnapshot!.documentChanges {
                 //   print("\(document.documentID) => \(document.data())")
                    let task: TaskItem
                    do {
                        task = try change.document.data(as: TaskItem.self)
                        print(task)
                    }
                    catch{
                        print("Unable to decode task. Is the hero malformed?")
                        return
                    }
                    
                    if task.isChecklist! {
                        var allChecklistItems: Set<ChecklistUnit> = []
                        for checklist in task.checklistItems {
                            guard let newChecklistItem = self.databaseController?.addChecklist(checklistDesc: checklist.checklistDescription!, isChecklist: checklist.isChecked!) else { return }
                            
                            allChecklistItems.insert(newChecklistItem)
                        }
                        // Checking if a priority label exists or not
                        if task.taskPriorityLabel == nil {
                            let _ = self.databaseController?.addTask(taskTitle: task.taskTitle!, taskDescription: "None", isChecklist: task.isChecklist!, checklistItems: allChecklistItems as NSSet, priorityLabel: .low)
                        }
                        else {
                            let _ = self.databaseController?.addTask(taskTitle: task.taskTitle!, taskDescription: "None", isChecklist: task.isChecklist!, checklistItems: allChecklistItems as NSSet, priorityLabel: task.taskPriorityLabel!)
                        }
                    }
                    else {
                        // Checking if a priority label exists or not
                        if task.taskPriorityLabel == nil {
                            let _ = self.databaseController?.addTask(taskTitle: task.taskTitle!, taskDescription: task.taskDescription!, isChecklist: task.isChecklist!, checklistItems: NSSet(), priorityLabel: .low)
                        }
                        else {
                            let _ = self.databaseController?.addTask(taskTitle: task.taskTitle!, taskDescription: task.taskDescription!, isChecklist: task.isChecklist!, checklistItems: NSSet(), priorityLabel: task.taskPriorityLabel!)
                        }
                    }
                }
                    
                }
            }
    }
    
    
    func onTaskChange(change: DatabaseChange, taskNote: TaskUnit) {
        //
        print("Triggered Single")
    }
    
    func onAllTasksChange(change: DatabaseChange, allTaskNote: [TaskUnit]) {
        print("Triggered")
        // This function gets triggered, when there is a change in database related to TaskUnit, so that collection view can get updated accordingly
        allTasks = allTaskNote
        if allTasks.count == 0 && self.shouldSync{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.syncWithFirebase()
            }
        }
        collectionView.reloadData()
    }
    
    @objc func pressed() {
        self.performSegue(withIdentifier: "createTaskSegue", sender: nil)
    }

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // To perform and update collection view according to the search results
        print("Inside")
        if !searchText.isEmpty {
            allTasks = (databaseController?.searchAllTasks(searchQuery: searchText))!
        }
        else {
            allTasks = (databaseController?.getAllTasks())!
        }
        collectionView.reloadData()
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


extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if allTasks.count == 0 {
            // This is basically used, when there are no tasks and database is empty
            collectionView.setEmptyMessage("No Tasks", UIImage(systemName: "archivebox")!)

        }
        else {
            collectionView.backgroundView  = nil
        }
        return allTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Getting the particular task according to the current row index
        
        let thisTask = allTasks[indexPath.row]
        
        if thisTask.isChecklist {
            // If it is a checklist task, inflating the collection cell which
            // supports checklist items
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChecklistTaskCollectionViewCell", for: indexPath) as! ChecklistTaskCollectionViewCell
            
            cell.populate(taskTitle: thisTask.taskTitle!, checklistItems: thisTask.checklistItems as! Set<ChecklistUnit>, priorityLabelColor: thisTask.priorityLabel)
            
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.6
            cell.layer.borderColor = UIColor.systemGray4.cgColor
            
            return cell
        }
        else {
            // Else populating the default cell, to show the task title and description with the appropriate label
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCollectionViewCell", for: indexPath) as! TaskCollectionViewCell
            
            cell.populate(taskTitle: thisTask.taskTitle!, taskDescription: thisTask.taskDescription!, priorityLabelColor: thisTask.priorityLabel)
            
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 0.6
            cell.layer.borderColor = UIColor.systemGray4.cgColor
            
            return cell
        }
        
    }
}


extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Fixing size of the cell
        let size = (collectionView.frame.size.width - 10)/2
        return CGSize(width: size, height: size)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

struct TaskTest {
    
    var taskTitle = "Something - 1"
    var isChecked = false
    var taskDescription = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo"
    
    var checklistDesc = "Trying ..."
    
}



extension UICollectionView {

        // Code Link - https://gist.github.com/furkanvijapura/3e0150787b3c535baabfb58484729624
        // Had to alter the code, according to my requirements and updated the constraint logic , with how the image content mode works
        // Making the whole process easier and faster
        func setEmptyMessage(_ message: String,_ img:UIImage) {
            
            let image = UIImageView()
            image.contentMode = .scaleToFill
            let screenSize: CGRect = UIScreen.main.bounds
            image.frame = CGRect(x: 0, y: 0, width: 50, height: screenSize.height * 0.4)
            image.image = img
            
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.boldSystemFont(ofSize: 20)
            messageLabel.textColor = .gray
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            
            let mainView = UIView()
            mainView.addSubview(image)
            mainView.addSubview(messageLabel)
           
            //Auto Layout
            image.translatesAutoresizingMaskIntoConstraints = false
            image.heightAnchor.constraint(equalToConstant: 50).isActive = true
            image.widthAnchor.constraint(equalToConstant: 60).isActive = true
            image.centerXAnchor.constraint(equalTo: mainView.centerXAnchor, constant: 10).isActive = true
            image.centerYAnchor.constraint(equalTo: mainView.centerYAnchor , constant: 0).isActive = true
            
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 10).isActive = true
            
            self.backgroundView = mainView
        }
        
    }
