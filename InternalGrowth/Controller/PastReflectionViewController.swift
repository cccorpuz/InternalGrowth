//
//  PastReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/19/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class PastReflectionViewController: UIViewController {

    @IBOutlet weak var reflectionPromptLabel: UILabel!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Date formatter
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        // Updating views based on info
        reflectionPromptLabel.text = reflections[selectedReflection].prompt
        keywordLabel.text = reflections[selectedReflection].keyword
        dateTimeLabel.text = formatter.string(from: reflections[selectedReflection].date)
        reflectionTextView.text = reflections[selectedReflection].reflection
    }
    
    @IBAction func onEditButtonPressed(_ sender: Any) {
        saveChangesButton.isEnabled = true
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        saveChangesButton.isEnabled = false
    }
    
    @IBAction func onReturnButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
