//
//  ExperiencesViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/24/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import CoreData

class ExperiencesViewController: UITableViewController {
    
    // MARK: - Global Variables
    
    var experiences = [Experience]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        loadExperiences()

    }
    
    // MARK: - IBActions
    @IBAction func onDoneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return experiences.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "experienceLabel", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = experiences[indexPath.row].name

        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if choosingExperience
        {
            self.dismiss(animated: true, completion: nil)
            selectedExperience = experiences[tableView.indexPathForSelectedRow!.row].name!
            print(selectedExperience)
            choosingExperience = false
        }
        else
        {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
    }
    
    // Bringing up reflections specific to selected experience
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TimelineViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedExperience = experiences[indexPath.row]
        }
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
    
    //MARK: - Data Manipulation Methods
    
    func saveExperiences() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadExperiences() {
        
        let request : NSFetchRequest<Experience> = Experience.fetchRequest()
        
        do{
            experiences = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
       
        tableView.reloadData()
        
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Experience", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newExperience = Experience(context: self.context)
            newExperience.name = textField.text!
            
            self.experiences.append(newExperience)
            
            self.saveExperiences()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new experience"
        }
        
        present(alert, animated: true, completion: nil)
        
    }

}
