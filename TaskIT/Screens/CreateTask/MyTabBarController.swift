//
//  MyTabBarController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 10/05/22.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
        
    // This class is responsible for setting up the main tab controller and all it's properties as needed

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneBtnClicked(_ sender: Any) {
        CreateTaskViewController().barButtonItemClicked()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // This method is just responsible for some prechecks before the user is actuallu transferred to some of the tabs available in the tab Controller
        guard let index = viewControllers?.index(of: viewController) else {
            return false
        }
        if index == 1 {
            let myView = self.viewControllers![0].children[0] as! HomeViewController
            myView.shouldSync = false
        }
        if index == 2 {

            let alert = UIAlertController(title: "Are you sure ?", message: "Do you want to shift to checklist mode ?", preferredStyle: .alert)

            let action1 = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
                tabBarController.selectedIndex = 2
            }

            let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                // Do nothing
            }


            alert.addAction(action1)
            alert.addAction(action2)

            present(alert, animated: true, completion: nil)
            return false
        }
        if index == 4 {
//            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "PriorityVC") {
//                tabBarController.present(newVC, animated: true)
//                return false
//            }
            let optionMenu = UIAlertController(title: "Choose Priority", message: "Each priority has different functionalities", preferredStyle: .actionSheet)
            
            let highPriority = UIAlertAction(title: "High Priority", style: .default){(action:UIAlertAction) in
                let myView = self.viewControllers![0].children[0] as! CreateTaskViewController
                myView.priorityLabel = .high
            }
            let mediumPriority = UIAlertAction(title: "Medium Priority", style: .default){(action:UIAlertAction) in
                
                let myView = self.viewControllers![0].children[0] as! CreateTaskViewController
                myView.priorityLabel = .medium
            }
            let lowPriority = UIAlertAction(title: "Low Priority", style: .default){(action:UIAlertAction) in
                let myView = self.viewControllers![0].children[0] as! CreateTaskViewController
                myView.priorityLabel = .low
                
            }

            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            
            optionMenu.addAction(highPriority)
            optionMenu.addAction(mediumPriority)
            optionMenu.addAction(lowPriority)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)

            
            return false
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
