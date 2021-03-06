//
//  QuickReflectionViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/17/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class QuickReflectionViewController: UIViewController {

    @IBOutlet weak var reflectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reflectionLabel.text = prompt
    }
    
    @IBAction func onCancelButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onGrowButtonPressed(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
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
