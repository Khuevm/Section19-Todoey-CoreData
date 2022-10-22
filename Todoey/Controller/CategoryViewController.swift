//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Khue on 20/10/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    // MARK: - Variable
    var categories: [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonDidTap(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                self.categories.append(newCategory)
                
                self.saveCategories()
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            
            saveCategories()
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulations
    func saveCategories(){
        do {
            try context.save()
        } catch {
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
}
