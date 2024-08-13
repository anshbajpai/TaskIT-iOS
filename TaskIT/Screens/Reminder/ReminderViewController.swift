//
//  ReminderViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 24/05/22.
//

import UIKit

class ReminderViewController: UIViewController {

    
    
    
    @IBOutlet weak var myDatePicker: UIDatePicker!
    
    var callback : ((Date) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func doneBtnClicked(_ sender: Any) {
        
        // This method get;s triggered, when user selects done on the reminder view controller
        // This sets up the date and initates the callback method so that value can be stored by appropriate variable
        // and notification can be scheduled
        let date = myDatePicker.date
        callback?(date)
        self.dismiss(animated: true, completion: nil)

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
