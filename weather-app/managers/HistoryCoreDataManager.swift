//
//  HistoryCoreDataManager.swift
//  weather-app
//
//  Created by user on 28/6/22.
//

import Foundation
import CoreData

class HistoryCoreDataManager {
    static var shared = HistoryCoreDataManager()
    
    func createHistoryNSManagedObject(place: String, position: Int16) -> History? {
        let context = CoreDataManager.shared.getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "History", in: context) else { return nil }
        
        guard let history = NSManagedObject(entity: entity, insertInto: context) as? History else { return nil }
        
        history.id = Int16.random(in: 1...1000)
        history.place = place
        history.position = position
        
        let formater = DateFormatter()
        formater.dateFormat = "MMM d yyy - HH:mm:ss"
        formater.locale = Locale(identifier: Locale.current.identifier)
        let dateStr = formater.string(from: Date())
        
        history.createdAt = dateStr
        
        return history
    }
    
    func checkHistoryItemInCoreData(place: String, position: Int16) -> Bool {

        let predicate = NSPredicate(format: "position == %d AND place == %@", position, place)
        
        let historyList = CoreDataManager.shared.getItemsInCoreData(predicate: predicate, entityName: "History")
        
        return (historyList.count > 0)
    }
    
    func getAllHistory() -> [History] {
        return CoreDataManager.shared.getItemsInCoreData(entityName: "History")
    }
    
    func removeHistoryItemFromCoreData(item: History) {
        CoreDataManager.shared.removeItemFromCoreData(item: item)
    }
}
