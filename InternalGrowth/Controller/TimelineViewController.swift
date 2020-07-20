//
//  SecondViewController.swift
//  InternalGrowth
//
//  Created by Crispin Corpuz on 7/14/20.
//  Copyright © 2020 Crispin Corpuz. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reflections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReflectionEntry")
        
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        let reflection = reflections[indexPath.row]
        print("row: ",indexPath.row)
        print("reflections: ", reflections.count)
        
        cell?.textLabel?.text = reflection.keyword + ", " + formatter.string(from: reflection.date)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        selectedReflection = indexPath.row
        performSegue(withIdentifier: "tableToDetailSegue", sender: cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Placeholder Reflection
        let exampleReflection = Reflection(prompt: "What is Internal Growth?", reflection: "Internal Growth is the best app for experiential reflections!", keyword: "Example", date: Date())
        reflections.append(exampleReflection)
    }
    
    @IBAction func onReturnButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

