//
//  QuickReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/17/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class QuickReflectionViewController: UIViewController {

    // MARK: - Global Variables
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var keywordTextField: UITextField!
    
    // Core Data fields
    var itemArray = [ReflectionEntry]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        promptLabel.text = prompt
    }
    
    // MARK: - IBAction functions
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        let item = ReflectionEntry(context: self.context)
        if let title = promptLabel.text {
            item.prompt = title
        }
        if let reflection = reflectionTextView.text {
            item.textReflection = reflection
        }
        if let keyword = keywordTextField.text {
            item.keyword = keyword
        }
        itemArray.append(item)
        saveItems()
        _ = self.dismiss(animated: true, completion: nil)
    }
    // MARK: - CoreData functions
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context in Quick Reflection, with debug error: \(error)")
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
