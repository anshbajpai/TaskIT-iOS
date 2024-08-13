//
//  SettingsViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 25/05/22.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController, UITableViewDelegate {

    // The basic functionality of this view controller, is to provide user extra flexibility towards the app
    // User can see quotes, check about the app and log out of the app accordingly
    
    @IBOutlet weak var tableView: UITableView!
    
    var indicator = UIActivityIndicatorView()


    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var quoteLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
         indicator.centerXAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.centerXAnchor),
         indicator.centerYAnchor.constraint(equalTo:
         view.safeAreaLayoutGuide.centerYAnchor)
        ])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        // As sson as the view appears, quote method is triggered so that user can see appropriate
        self.getQuoteFromApi()
    }
    
    
    
    func getQuoteFromApi() {
        
        // This method is responsible for conducting the API request and retrieving the Quote Data
        
        var request = URLRequest(url: URL(string: "https://api.quotable.io/random")!,timeoutInterval: Double.infinity)
        
        
        // Performing Operatiom
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            
            return
          }
            
            
            print(String(data: data, encoding: .utf8)!)
            
            do{
                // Converting the JSON respone back to QuoteData decodable class, to access variables from thr recieved response
            let decoder = JSONDecoder()
            let quoteData = try decoder.decode(QuoteData.self, from: data)

                
                
            // Performing the UI operation, inside main thread
            DispatchQueue.main.async {
                // Stopping the indicator loading sign
                self.indicator.stopAnimating()

                // Updating the view, with the retrieved quoteData from the API
                self.quoteLabel.text = quoteData.content

                //self.present(alert, animated: true, completion: nil)
            }
                
            }
            catch let error {
                print(error)
                self.displayMessage(title: "Error", message: "Couldn't load the quote. Try Again!")
            }
            
        }
        
        // Resuming task thread for further operations
        task.resume()
        
    
        


            
            
            
            
    }
    
    
    func logOutFromApp(){
        // This method is responsible for logging out of the application
        
        // Showing user an alert message, before performing the operation
        let alert = UIAlertController(title: "Log Out", message: "Are you sure, you want to logout from TaskIT ?", preferredStyle: .alert)
        
        
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
            
            
            let firebaseAuth = Auth.auth()
            
            do {
                // Performing sign out
              try firebaseAuth.signOut()
                
                
                // If sign out is successfull it is important, for the app to delete all it's content from app core data as well
                self.databaseController?.deleteAllTasks()
//                self.databaseController?.deleteAllChecklistItems()
                
                // Transferring the user back to SignupViewController
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "SignupVC") as! SignupViewController
                newViewController.modalPresentationStyle = .fullScreen
                
                let navViewController = UINavigationController(rootViewController: newViewController)
                
                navViewController.modalPresentationStyle = .fullScreen

                self.present(navViewController, animated: true, completion: nil)
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
        
        
        let action2 = UIAlertAction(title: "Cancel", style: .cancel) {
            (action:UIAlertAction) in
            
            
        }
        
        
        alert.addAction(action1)
        alert.addAction(action2)

        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // This table view is just handling showing, the different options available to the user in settings
        
        if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            indicator.startAnimating()
            self.getQuoteFromApi()
        }
        
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            self.logOutFromApp()
        }
        
        if indexPath.row == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "aboutSegue", sender: nil)
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


extension SettingsViewController: UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of options available to the user in settings screen
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Populating the table view with content as needed and with appropriate styling
        let cell = UITableViewCell()
        if(indexPath.row == 0){
            cell.textLabel!.text = "Log out"
            cell.textLabel?.textColor = .red
        }
        else if indexPath.row == 1 {
            cell.textLabel!.text = "See a Quote"
        }
        else {
            cell.textLabel!.text = "About"
        }
    

        return cell
        
    }
    
    
    
    
    
    
}
