//
//  SecondViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/14/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import CoreData

class TimelineViewController: UITableViewController {
    
    // MARK: - Global Variables
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - IBOutlets
    @IBOutlet weak var reflectionSearchBar: UISearchBar!
    
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReflectionEntry")
        
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        let reflection = itemArray[indexPath.row]
        print("row: ",indexPath.row)
        print("reflections: ", itemArray.count)
        
        if let keyword = reflection.keyword {
            cell?.textLabel?.text = keyword + ", " + reflection.date!
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        selectedReflection = indexPath.row
        performSegue(withIdentifier: "tableToDetailSegue", sender: cell)
    }
    
    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        reflectionSearchBar.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        loadItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - CoreData Functions
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<ReflectionEntry> = ReflectionEntry.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentExperience.name MATCHES %@", selectedExperience!.name!)
        let userPredicate = NSPredicate(format: "userReflectionParent.userEmail MATCHES %@", currentUser!.userEmail!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, userPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }

}

//MARK: - Search bar methods

extension TimelineViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<ReflectionEntry> = ReflectionEntry.fetchRequest()
    
        let predicate = NSPredicate(format: "keyword CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "keyword", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}

