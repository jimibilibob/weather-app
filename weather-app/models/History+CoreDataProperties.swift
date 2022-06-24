//
//  History+CoreDataProperties.swift
//  weather-app
//
//  Created by user on 24/6/22.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var id: Int16
    @NSManaged public var place: String
    @NSManaged public var position: Int16
    @NSManaged public var createdAt: String?
}

extension History : Identifiable {

}
