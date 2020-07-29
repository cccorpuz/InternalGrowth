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

    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var experiencesSearchBar: UISearchBar!
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        experiencesSearchBar.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        loadExperiences()

    }
    
    // MARK: - IBActions
    @IBAction func onDoneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onInfoButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "How This Page Works", message: "\n 1. Click on the \"+\" to add an experience you want to reflect on.\n\n 2. Swipe left to delete an experience.\n\n 3. Click on the experience to see your Reflection Timeline!" , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            targetExperience = experiences[tableView.indexPathForSelectedRow!.row]
            print(targetExperience!.name!)
            targetExperienceString = targetExperience!.name!
            self.dismiss(animated: true, completion: nil)
            choosingExperience = false
        }  else {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
    }
    
    // Bringing up reflections specific to selected experience
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let indexPath = tableView.indexPathForSelectedRow {
            selectedExperience = experiences[indexPath.row]
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let alert = UIAlertController(title: "Do you want to delete this experience?", message: "This action is irreversible and this experience and ALL associated reflections will be lost forever. Continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.loadExperiences()
                let commit = experiences[indexPath.row]
                self.context.delete(commit)
                experiences.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.saveExperiences()
            }))
            self.present(alert, animated: true, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    /*
     Old loadExperiences() function
     */
//    func loadExperiences() {
//
//        let request : NSFetchRequest<Experience> = Experience.fetchRequest()
//
//        do {
//            experiences = try context.fetch(request)
//        } catch {
//            print("Error loading categories \(error)")
//        }
//
//        tableView.reloadData()
//
//    }
    
    func loadExperiences(with request: NSFetchRequest<Experience> = Experience.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentUser.userEmail MATCHES %@", currentUser!.userEmail! )
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            experiences = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Add New Experiences

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Experience", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newExperience = Experience(context: self.context)
            newExperience.name = textField.text!
            newExperience.parentUser = currentUser
            
            if !newExperience.name!.isEmpty
            {
                experiences.insert(newExperience, at: 0)
                self.saveExperiences()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new experience"
        }
        
        present(alert, animated: true, completion: nil)
        
    }

}

//MARK: - Search bar methods

extension ExperiencesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Experience> = Experience.fetchRequest()
    
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadExperiences(with: request, predicate: predicate)
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadExperiences()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}
