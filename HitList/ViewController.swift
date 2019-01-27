//
//  ViewController.swift
//  HitList
//
//  Created by Henning Hontheim on 25.01.19.
//  Copyright © 2019 Henning Hontheim. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        // 1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        // 3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    @IBAction func clearList(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Clear List", message: "Do you really want to clear the list?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) {
            [unowned self] action in
            
            self.askForConfirmation()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func askForConfirmation() {
        
        let alert = UIAlertController(title: "Confirmation", message: "Please type \"confirm\" to clear the list. This cannot be un-done!", preferredStyle: .alert)
        
        let confirmAcrion = UIAlertAction(title: "Delete", style: .destructive) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let confirmation = textField.text else {
                    return
            }
            
            self.deleteList(wasConfirmed: confirmation.elementsEqual("confirm"))
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            [unowned self] action in
            
            self.showConfirmAlert(hasBeenDeleted: false)
        }
        
        alert.addTextField()
        
        alert.addAction(confirmAcrion)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func deleteList(wasConfirmed: Bool) {
        if wasConfirmed {
            clearList()
            
            // 1
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 2
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
            
            // 3
            do {
                people = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
            showConfirmAlert(hasBeenDeleted: true)
        } else {
            showConfirmAlert(hasBeenDeleted: false)
        }
    }
    
    func showConfirmAlert(hasBeenDeleted: Bool) {
        
        let alert: UIAlertController
        
        if hasBeenDeleted {
            alert = UIAlertController(title: "Cleared", message: "The list has been cleared", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Cancellation", message: "The list has not been cleared!", preferredStyle: .alert)
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
        
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        person.setValue(name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func clearList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                appDelegate.persistentContainer.viewContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data error :", error)
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
    
}
