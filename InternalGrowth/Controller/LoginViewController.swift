//
//  LoginViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/23/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Global var
    
    /// This allows CoreData to have a defined context to operate upon when using the four main functions:
    /// Create, Retrieve, Update, Delete (CRUD).
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    //MARK: - UI Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard Pod declaration
        self.hideKeyboardWhenTappedAround()
        
        // Authentication Persistence
        // Initially will listen for if the user signs in or out
        let _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            /*
             This happens if the user is already signed in.
             userEmail and currentUser are set here if not already done
             */
            if Auth.auth().currentUser != nil {
                if let email = user?.email {
                    print(email)
                    do
                    {
                        if try userArray.contains(where: {one in one.userEmail == email}) {
                            currentUser = userArray.filter({two in two.userEmail == email})[0]
                        }
                        else
                        {
                            let user = User(context: self.context)
                            user.userEmail = email
                            userArray.append(user)
                            self.saveUsers()
                            currentUser = user
                        }
                    } catch {
                        print("stuff")
                    }
                }
                self.signedIn = true
                self.signingIn = false
               
                // Setting view controller
                if self.signedIn && !self.signingIn {
                    print("User logged in previously, going to main page")
                    self.performSegue(withIdentifier: "GoToMainSegue", sender: self)
                }
            } else {
                // No user is signed in.
                // ...
                print("User not logged in")
                targetExperience = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        goButton.layer.cornerRadius = goButton.frame.height/2
        forgotPasswordButton.layer.cornerRadius = forgotPasswordButton.frame.height/2
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - Login page views
    var signingIn : Bool = true
    var signedIn : Bool = false

    @IBOutlet weak var signInUpOptionSegmentedControlOutlet: UISegmentedControl!
    @IBOutlet fileprivate weak var loginTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet fileprivate weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // MARK: - Handling Sign In vs Sign Up
    @IBAction func onSignInUpOptionSegmentedControlChanged(_ sender: Any) {
        // *** Change this to a ternary operator in the future to be more concise and efficient ***
        if signInUpOptionSegmentedControlOutlet.selectedSegmentIndex == 0
        {
            signingIn = true
            print(signingIn)
            goButton.setTitle("Sign In", for: .normal)
            confirmPasswordTextField.isEnabled = false
            confirmPasswordTextField.isHidden = true
            forgotPasswordButton.isEnabled = true
            forgotPasswordButton.isHidden = false
        }
        else
        {
            signingIn = false
            print(signingIn)
            goButton.setTitle("Sign Up", for: .normal)
            confirmPasswordTextField.isEnabled = true
            confirmPasswordTextField.isHidden = false
            forgotPasswordButton.isEnabled = false
            forgotPasswordButton.isHidden = true
        }
    }
    
    @IBAction func onForgotPasswordButtonPressed(_ sender: Any) {
        forgotPassword()
    }
    
    
    //MARK: - Authentication/Account Creation
    @IBAction func onGoButtonPressed(_ sender: Any) {
        let email = loginTextField.text!
        let password = passwordTextField.text!
        let confirm = confirmPasswordTextField.text
        if (!signingIn && password == confirm && confirm != "")
        {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                // Check for authentication error
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if self.signedIn {
                        self.signedIn = false
                        self.signingIn = true
                    } else {
                        let user = User(context: self.context)
                        user.userEmail = email
                        userArray.append(user)
                        self.saveUsers()
                        self.performSegue(withIdentifier: "GoToMainSegue", sender: self)
                    }
                }
            }
        }
        else if (signingIn)
        {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                // Check for authentication error
                if let error = error {
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Sign In Error", message: "Email and/or password do not match our records.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    if self!.signedIn {
                        self!.signedIn = false
                        self!.signingIn = true
                    } else {
                        self?.performSegue(withIdentifier: "GoToMainSegue", sender: self)
                    }
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: "Unable to Signup", message: "Please fill in all fields and double check password matches confirmation.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Password Handler functions
    func forgotPassword()
    {
        var textField = UITextField()
        let alert = UIAlertController(title: "Forgot Password", message: "Enter email to send password reset instructions to:", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Email"
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: "Send Email", style: .default, handler: { (action) in
            if let email = textField.text {
                self.resetEmailSent(with: email)
                print("Email sent")
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }

    func resetEmailSent(with email : String)
    {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
        }
    }
    
    // MARK: - CoreData functions
    
    func saveUsers() {
        do {
         try context.save()
       } catch {
          print("Error saving user email, with debug error: \(error)")
       }
    }
    
}

// MARK: - Dismissing keyboard extension
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
