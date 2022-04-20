//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Iliya Mayasov on 19.04.2022.
//

import UIKit

class GoalListViewController: UITableViewController {
    
    //MARK: - Private Properties
    private var goalList: [Goal] = []
    private let cellID = "Goal"

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }

    //MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Goal List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Goal", and: "What do you want to do?")
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { goalList in
            self.goalList = goalList
        }
    }
    
    private func showAlert(with title: String, and message: String, index: Int? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let goal = alert.textFields?.first?.text, !goal.isEmpty else { return }
            
            if title == "New Goal" {
                self.save(goal)
            } else {
                guard let index = index else { return }
                self.change(goal, index)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            
            if title == "New Goal" {
                textField.placeholder = "New Goal"
            } else {
                guard let index = index else { return }
                textField.text = self.goalList[index].title
            }
            
        }
        present(alert, animated: true)
    }
    
    private func save(_ goalName: String) {
        
        StorageManager.shared.saveData(for: goalName) { goal in
            self.goalList.append(goal)
        }
        
        let cellIndex = IndexPath(row: goalList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func change(_ goalName:  String, _ index: Int) {
        let goal = goalList[index]
        goal.title = goalName
        StorageManager.shared.changeData()
        tableView.reloadData()
    }
}

// MARK: - UITAbleViewDataSource
extension GoalListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        goalList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let goal = goalList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = goal.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Update Goal", and: "What do you want to do?", index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension GoalListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let goal = goalList[indexPath.row]
            goalList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.deleteData(for: goal)
        }
    }
}


