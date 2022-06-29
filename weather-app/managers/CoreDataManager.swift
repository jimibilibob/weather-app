//
//  CoreDataManager.swift
//  weather-app
//
//  Created by user on 24/6/22.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static var shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "weather_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // MARK: - Core Data Saving support

    func saveContext () {
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
    
    func saveItemInCoreData<T: NSManagedObject>(item: T) {
        let context = getContext()
        context.insert(item)
        
        CoreDataManager.shared.saveContext()
    }
    
    func getItemsInCoreData<T: NSManagedObject>(predicate: NSPredicate, entityName: String) -> [T] {
        let context = getContext()
        
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)

        fetchRequest.predicate = predicate

        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    func getItemsInCoreData<T: NSManagedObject>(entityName: String) -> [T] {
        let context = getContext()
        
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        
        do {
            return try context.fetch(fetchRequest)
        } catch(let error) {
            print(error)
            return []
        }
    }
    
    func removeItemFromCoreData<T: NSManagedObject>(item: T) {
        let context = getContext()
        context.delete(item)
        CoreDataManager.shared.saveContext()
    }
}
