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
    var itemArray = [ReflectionEntry]()
    
    var selectedExperience : Experience? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - IBOutlets

    
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
            cell?.textLabel?.text = keyword + ", " + formatter.string(from: Date())
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
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
    }
    
    // MARK: - CoreData Functions
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }

    func loadItems(with request: NSFetchRequest<ReflectionEntry> = ReflectionEntry.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentExperience.name MATCHES %@", selectedExperience!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
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
    
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
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

