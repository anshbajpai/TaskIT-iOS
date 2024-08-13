//
//  AboutTableViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 09/06/22.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    // This view controller, is just to show the different sources and libraries used in this application
    
    var allAboutInfo: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        
        allAboutInfo.append("Custom CheckBox UI - Source (https://www.youtube.com/watch?v=chj2ceZl51s) ")
        allAboutInfo.append("OnBoarding Logic and Figuring out indicator update - Source (https://www.youtube.com/watch?v=VMiaNFabsZA) ")
        allAboutInfo.append("Firebase - For implementing LogIn and Database Management")
        allAboutInfo.append("FacebookSDK - For giving user the easy abilty to sign in through their Facebook Account")
        allAboutInfo.append("FIT3178 Unit Notes/Lecture Video content")
        allAboutInfo.append("All images used are imported from either iconfinder.com / flaticons / SF Symbols under appropriate licenses")
        allAboutInfo.append("In Works Image - https://www.flaticon.com/free-icon/work-in-progress_5578703?term=under%20construction&page=1&position=1&page=1&position=1&related_id=5578703&origin=search# ")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allAboutInfo.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Populating table view with values from the data source according to the index path
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)

        let currentInfo = allAboutInfo[indexPath.row]
        cell.textLabel!.text = currentInfo

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
