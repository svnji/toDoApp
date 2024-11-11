//
//  ViewController.swift
//  toDo
//
//  Created by Daddy on 09/11/2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    

    @IBOutlet weak var taskTxt: UITextField!
    @IBOutlet weak var addTaskBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var items:[TaskCell]?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
        refreshControl.tintColor = UIColor(named: "gray")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func fetchData() {
        let request = TaskCell.fetchRequest() as NSFetchRequest<TaskCell>
        
        // Sort by completion state or other criteria, if needed
        let sort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    func toggleTaskCompletion(_ task: TaskCell, at indexPath: IndexPath) {
        task.isCompleted.toggle()
        
        // Save the updated completion state to Core Data
        self.saveData()
        
        // Reload the specific row to update its UI without affecting other cells
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! taskTableViewCell
            let task = self.items![indexPath.row]
            
            cell.configureCell(with: task)
            
            // Handle completion toggle
            cell.toggleCompletion = { [weak self] in
                self?.toggleTaskCompletion(task, at: indexPath)
            }

            return cell
        }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        let taskText = taskTxt.text
        //create task object
        let newTask = TaskCell(context: self.context)
        newTask.title = taskText
        //save data
        self.saveData()
        //refetch teh data
        self.fetchData()
        tableView.reloadData()
        taskTxt.text = ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = self.items![indexPath.row]
        let alert = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
        
        alert.addTextField()
        
        let textField = alert.textFields![0]
        textField.text = task.title
        
        // Save Button
        let saveBtn = UIAlertAction(title: "Save!", style: .default) { (action) in
            // Edit the title
            let textField = alert.textFields![0]
            task.title = textField.text
            // Save the updated task data
            self.saveData()
            // Refetch the data to update the UI
            self.fetchData()
        }
        
        // Cancel Button
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Dismiss the alert without making any changes
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(saveBtn)
        alert.addAction(cancelBtn)  // Add the cancel button
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }

    @objc func refresh() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    @IBAction func editBtnTapped(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var items = items else { return }
        
        // Move the item within the array
        let movedTask = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(movedTask, at: destinationIndexPath.row)
        
        // Update the `order` attribute based on the new positions
        for (index, task) in items.enumerated() {
            task.order = Int64(index)
        }
        
        // Save the context to persist the new order
        self.saveData()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {(action,view, completionHandler) in
            //the task you wanna remove
            let taskToRemove = self.items![indexPath.row]
            
            //remove it
            self.context.delete(taskToRemove)
            //save
            self.saveData()
            //refetch
            self.fetchData()
            
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Failed to save reordered data: \(error)")
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

