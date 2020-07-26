//
//  ProfileViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/23/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreData

class ProfileViewController: UIViewController {

    // MARK: - Global Variables
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var categoriesCountLabel: UILabel!
    @IBOutlet weak var reflectionsCountLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        loadExperiences()
//        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userEmailLabel.text = userEmail
        categoriesCountLabel.text = "\(experiences.count)"
        reflectionsCountLabel.text = "\(itemArray.count)"
    }
    
    // MARK: - IBAction Functions
    @IBAction func onSignOutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "LogoutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
          
    }
    
    @IBAction func onGoBackButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCategoriesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func onReflectionsButtonPressed(_ sender: Any) {
        
    }
    
    // MARK: - CoreData Functions
    // Just here to load everything, so profile is correct

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
                
    }
    
    func loadExperiences() {
        
        let request : NSFetchRequest<Experience> = Experience.fetchRequest()
        
        do {
            experiences = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
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
