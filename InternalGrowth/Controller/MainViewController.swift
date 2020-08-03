//
//  MainViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/14/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import Foundation
import UIKit
import Floaty

class MainViewController: UIViewController, FloatyDelegate {

    // MARK: - Global Variables
    var floaty = Floaty()       // Floating button in bottom right corner
    var prompts = Prompts()     // Prompts Object
    var gradientLayer: CAGradientLayer! // gradient object
    
    // Global Variables
    var buttonWidth = CGFloat.init()    // Width of the Quick Prompt Buttons
    var viewWidth = CGFloat.init()      // Width of the Screen
    var timer1 = Timer()                // Timer to move buttons across screen
    var timer2 = Timer()                // Timer to move buttons across screen
    var timer3 = Timer()                // Timer to move buttons across screen
    
    // MARK: - IBActions
    @IBOutlet weak var QuickPrompt1Button : UIButton!
    @IBOutlet weak var QuickPrompt2Button : UIButton!
    @IBOutlet weak var QuickPrompt3Button : UIButton!
    
    @IBAction func QuickPrompt1Button (_ sender: UIButton!)
    {
        prompts.selectedPrompt = QuickPrompt1Button
        prompt = QuickPrompt1Button.currentTitle!
    }
    @IBAction func QuickPrompt2Button (_ sender: UIButton!)
    {
        prompts.selectedPrompt = QuickPrompt2Button
        prompt = QuickPrompt2Button.currentTitle!
    }
    @IBAction func QuickPrompt3Button (_ sender: UIButton!)
    {
        prompts.selectedPrompt = QuickPrompt3Button
        prompt = QuickPrompt3Button.currentTitle!
    }
    
    // MARK: - View functions
    override func viewDidLoad() {
        super.viewDidLoad()
      
        generateFloatingButton()
        
        // Find the button's width and height
        buttonWidth = QuickPrompt1Button.frame.width
        print(buttonWidth)

        // Find the width and height of the enclosing view
        viewWidth = QuickPrompt1Button.superview!.bounds.width
        print(viewWidth)
        
        
        timer1 = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(timerAction1), userInfo: self, repeats: true)
        
        timer2 = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(timerAction2), userInfo: self, repeats: true)
        
        timer3 = Timer.scheduledTimer(timeInterval: 0.018, target: self, selector: #selector(timerAction3), userInfo: self, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        // Background color setting
        createGradientLayer()
        
        // To give buttons rounded corners:
        QuickPrompt1Button.layer.cornerRadius = 30;
        QuickPrompt2Button.layer.cornerRadius = 30;
        QuickPrompt3Button.layer.cornerRadius = 30;

        // To give buttons rounded corners:
        QuickPrompt1Button?.layer.cornerRadius = 30;
        QuickPrompt2Button?.layer.cornerRadius = 30;
        QuickPrompt3Button?.layer.cornerRadius = 30;
        
        // Setting prompts
        updatePrompts()
        
    }
    
    // MARK: - UI Programmatic styling functions
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Floating button functions
    @IBAction func endEditing() {
      view.endEditing(true)
    }
    
    @IBAction func customImageSwitched(_ sender: UISwitch) {
      if sender.isOn == true {
        floaty.buttonImage = UIImage(named: "custom-add")
      } else {
        floaty.buttonImage = nil
      }
    }
    
    func generateFloatingButton() {
        /*
         Notes :
            -Floaty item objects can be found by calling >> items[index]
            -Titles appear on each button (--- *.additem(title : String, icon : UIImage) {item in ...} ---)
            -They are displayed as such :   lower index -> closer to floating button
                                            higher index -> further from floating button

        General format for new items
-------------------------------------------------------------
        let item = FloatyItem()

        // item visual properties
        item.hasShadow = true
        item.buttonColor = UIColor.blue
        item.circleShadowColor = UIColor.red

        // item label-name
        item.titleShadowColor = UIColor.blue
        item.titleLabelPosition = .left
        item.title = "titlePosition left"

        // how item handles selection
        item.handler = { item in

        }

        // adding to item list
        floaty.addItem(item: item)
         floaty.addItem(title: "I got a title")
         floaty.addItem("I got a icon", icon: UIImage(named: "icShare"))
         floaty.addItem("I got a handler", icon: UIImage(named: "icMap")) { item in
            let alert = UIAlertController(title: "Hey", message: "I'm hungry...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Me too", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
         }
-------------------------------------------------------------
         */
        
        // Reflection button option
        //      Will appear at bottom
        let newReflection = FloatyItem()
        newReflection.hasShadow = true
        newReflection.buttonColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        newReflection.circleShadowColor = UIColor.gray
        newReflection.titleShadowColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        newReflection.titleLabelPosition = .left
        newReflection.title = "Fully Reflect!"
        
        // Open Full Reflection Storyboard
        newReflection.handler = {item in
            let storyBoard : UIStoryboard = UIStoryboard(name: "FullReflection", bundle: nil)
            let fullReflectionViewController = storyBoard.instantiateViewController(withIdentifier: "FullReflection")
            fullReflectionViewController.modalPresentationStyle = .fullScreen
            self.present(fullReflectionViewController, animated: true, completion: nil)
        }
        floaty.addItem(item: newReflection)
        
        // Library Timeline button option
        //      Will appear above newReflection
        let goToLibrary = FloatyItem()
        goToLibrary.hasShadow = true
        goToLibrary.buttonColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        goToLibrary.circleShadowColor = UIColor.gray
        goToLibrary.titleShadowColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        goToLibrary.titleLabelPosition = .left
        goToLibrary.title = "Reflection Timeline"
        goToLibrary.handler = {item in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Timeline", bundle: nil)
            let reflectionTimelineViewController = storyBoard.instantiateViewController(withIdentifier: "TimelineNavigation")
            reflectionTimelineViewController.modalPresentationStyle = .fullScreen
            self.present(reflectionTimelineViewController, animated: true, completion: nil)
        }
        floaty.addItem(item: goToLibrary)
        
        // Go to profile page
        let profile = FloatyItem()
        profile.hasShadow = true
        profile.buttonColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        profile.circleShadowColor = UIColor.gray
        profile.titleShadowColor = UIColor.init(red: CGFloat(146.0/255.0), green: CGFloat(133.0/255.0), blue: CGFloat(229.0/255.0), alpha: 1.0)
        profile.titleLabelPosition = .left
        profile.title = "Profile"
        profile.handler = { item in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileNavigation")
            profileViewController.modalPresentationStyle = .fullScreen
            self.present(profileViewController, animated: true, completion: nil)
        }
        floaty.addItem(item: profile)
        
        // Big plus button has a shadow
        floaty.hasShadow = true

        // padding at bottom right of screen
        floaty.paddingX = floaty.paddingY
        floaty.fabDelegate = self

        self.view.addSubview(floaty)
      
    }
    
    //MARK: - Updating buttons with prompts
    func updatePrompts() {
        var promptList : [String] = []
        
        let docRef = db.collection("Prompts").document("doc1")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                for item in document.data()! {
                    promptList.append(item.value as! String)
                }
                for i in 0 ... 2 {
                    let index = Int.random(in: 0 ..< promptList.count)
                    self.prompts.prompts[i] = promptList[index]
                    promptList.remove(at: index)
                }
                
                self.QuickPrompt1Button?.setTitle(self.prompts.prompts[0], for: .normal)
                self.QuickPrompt2Button?.setTitle(self.prompts.prompts[1], for: .normal)
                self.QuickPrompt3Button?.setTitle(self.prompts.prompts[2], for: .normal)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //MARK: - Timers for button clouds
    @objc func timerAction1() {
        if QuickPrompt1Button.center.x >= viewWidth + buttonWidth / 2 {
            QuickPrompt1Button.center.x = CGFloat.init() - buttonWidth / 2
        }
        else {
            QuickPrompt1Button.center.x += 1
        }
    }
    
    @objc func timerAction2() {
        if QuickPrompt2Button.center.x >= viewWidth + buttonWidth / 2 {
            QuickPrompt2Button.center.x = CGFloat.init() - buttonWidth / 2
        }
        else {
            QuickPrompt2Button.center.x += 1
        }
    }
    
    @objc func timerAction3() {
        if QuickPrompt3Button.center.x >= viewWidth + buttonWidth / 2 {
            QuickPrompt3Button.center.x = CGFloat.init() - buttonWidth / 2
        }
        else {
            QuickPrompt3Button.center.x += 1
        }
    }
    
    // MARK: - Floaty Delegate Methods
    func floatyWillOpen(_ floaty: Floaty) {
      print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
      print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
      print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
      print("Floaty Did Close")
    }
}



