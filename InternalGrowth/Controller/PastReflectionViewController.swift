//
//  PastReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import CoreData

class PastReflectionViewController: UIViewController {
    
    // MARK: - Global Variables

    @IBOutlet weak var reflectionPromptLabel: UILabel!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Date formatter
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        // Updating views based on info
        reflectionPromptLabel.text = itemArray[selectedReflection].prompt
        keywordLabel.text = itemArray[selectedReflection].keyword
        dateTimeLabel.text = itemArray[selectedReflection].date
        reflectionTextView.text = itemArray[selectedReflection].textReflection
    }
    
    // MARK: - IBAction functions
    
    @IBAction func onEditButtonPressed(_ sender: Any) {
        reflectionTextView.isEditable = true
        saveChangesButton.isEnabled = true
        editButtonItem.isEnabled = false
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        reflectionTextView.isEditable = false
        saveChangesButton.isEnabled = false
        editButtonItem.isEnabled = true
        
        itemArray[selectedReflection].prompt = reflectionPromptLabel.text
        itemArray[selectedReflection].keyword = keywordLabel.text
        itemArray[selectedReflection].textReflection =         reflectionTextView.text
        saveItems()
    }
    
    @IBAction func onDeleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Deleting Reflection", message: "Are you sure you want to delete this reflection?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.context.delete(itemArray[selectedReflection])
            itemArray.remove(at: selectedReflection)
            self.saveItems()
            self.performSegue(withIdentifier: "unwindToTimeline", sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    // MARK: - CoreData functions
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context in Full Reflection, with debug error: \(error)")
        }
        
        // self.tableView.reloadData()
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
