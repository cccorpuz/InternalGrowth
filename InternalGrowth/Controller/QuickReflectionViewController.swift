//
//  QuickReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/17/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class QuickReflectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    // MARK: - Global Variables
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var chooseExperienceButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var growButton: UIButton!
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // String to rename Experience button
    var newTargetExperience : String = ""
    
    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        promptLabel.text = prompt
        chooseExperienceButton.layer.cornerRadius = chooseExperienceButton.frame.size.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.size.height/2
        growButton.layer.cornerRadius = growButton.frame.size.height/2
        if let targetExperience = targetExperience {
            chooseExperienceButton.setTitle(targetExperience.name, for: .normal)
        }
        else
        {
            chooseExperienceButton.setTitle("Choose Experience", for: .normal)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        if (segue.identifier == "chooseExperienceSegueFromQuickReflection")
//        {
//            let experienceVC = ExperiencesViewController()
//            experienceVC.delegate = self
//            present(experienceVC, animated: true)
//        }
//        // Pass the selected object to the new view controller.
//    }
    
    // MARK: - UI Functions
    
    func updateUI() {
        chooseExperienceButton.setTitle(newTargetExperience, for: .normal)
    }

    // MARK: - IBAction functions
    
    @IBAction func onVideoButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Visual Reflection", message: "Select a source for this reflection:", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Your Videos", style: .default, handler: { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "New Video Reflection", style: .default, handler: { (action) in
            VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        let item = ReflectionEntry(context: self.context)
        if let targetExperience = targetExperience, let keyword = keywordTextField.text {
            if let title = promptLabel.text {
                item.prompt = title
            }
            if let reflection = reflectionTextView.text {
                item.textReflection = reflection
            }
            item.keyword = keyword
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            let dateSaved = formatter.string(from: Date())
            item.date = dateSaved
            item.parentExperience = targetExperience
            item.userReflectionParent = currentUser
            targetExperience.parentUser = currentUser
            itemArray.append(item)
            saveItems()
            _ = self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Incomplete Entry", message: "Please ensure you have a keyword and selected experience to add this reflection to. This helps us help you grow the right tree!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onChooseExperienceButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "chooseExperienceSegueFromQuickReflection", sender: self)
        choosingExperience = true
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
