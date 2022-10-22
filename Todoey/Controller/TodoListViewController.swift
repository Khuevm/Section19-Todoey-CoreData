//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    // MARK: - IBOutlet
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Variable
    let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    var items: [Item] = []
    var selectedCategory: Category? {
        // didSet dc gọi ngay khi biến có giá trị
        didSet {
            loadItems()
        }
    }
    
    //Access to AppDelegate as object to get property
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        print(dataFilePath)
        loadItems()
        
    }
    
    // MARK: - IBAction
    @IBAction func addButtonDidTap(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //What will happen if user tap the Add Item Button
            if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
                //Create in CRUD
                let newItem = Item(context: self.context)
                newItem.title = textField.text
                newItem.isDone = false
                newItem.parentCategory = self.selectedCategory
                
                self.items.append(newItem)
                
                self.saveItems()
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentItem = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = currentItem.title
        cell.accessoryType = currentItem.isDone ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete in CRUD
            let currentIndex = indexPath.row
            context.delete(items[currentIndex])
            items.remove(at: currentIndex)
            
            saveItems()
        }
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Update in CRUD
//        items[indexPath.row].setValue(!items[indexPath.row].isDone, forKey: "isDone")
        items[indexPath.row].isDone = !items[indexPath.row].isDone
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Data Manipulations
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("Error encoding data \(error)")
        }
        tableView.reloadData()
    }
    
    //Read in CRUD
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), _ predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        } else {
            let request = Item.fetchRequest()

            //filter
            //[cd]: c-ko phân biệt chữ hoa chữ thường, d-ko phân biệt có dấu
            let predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)

            //sort
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

            loadItems(with: request, predicate)
        }
    }
}
