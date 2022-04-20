//
//  StorageManager.swift
//  CoreDataApp
//
//  Created by Iliya Mayasov on 19.04.2022.
//

import CoreData
import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Public Methods
    func saveData(for goalName: String, completion: @escaping(Goal) -> Void) {
        let goal = Goal(context: viewContext)
        goal.title = goalName
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        completion(goal)
    }
    
    func changeData() {
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func deleteData(for goal: Goal) {
        viewContext.delete(goal)
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func fetchData(completion: @escaping([Goal]) -> Void) {
        var goalList: [Goal] = []
        let fetchRequest = Goal.fetchRequest()
        
        do {
            goalList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        completion(goalList)
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
}
