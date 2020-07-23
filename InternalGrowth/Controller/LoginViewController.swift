//
//  LoginViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/23/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // Login page views
    var signingIn : Bool = true

    @IBOutlet weak var signInUpOptionSegmentedControlOutlet: UISegmentedControl!
    @IBOutlet fileprivate weak var loginTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var confirmPasswordTextField: UITextField!
    
    @IBAction func onSignInUpOptionSegmentedControlChanged(_ sender: Any) {
        // *** Change this to a ternary operator in the future to be more concise and efficient ***
        if signInUpOptionSegmentedControlOutlet.titleForSegment(at: 0) == "Sign In"
        {
            signingIn = true
            print(signingIn)
            confirmPasswordTextField.isEnabled = false
            confirmPasswordTextField.isHidden = true
        }
        else
        {
            signingIn = false
            print(signingIn)
            confirmPasswordTextField.isEnabled = true
            confirmPasswordTextField.isHidden = false
        }
    }
    @IBAction func onGoButtonPressed(_ sender: Any) {

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
