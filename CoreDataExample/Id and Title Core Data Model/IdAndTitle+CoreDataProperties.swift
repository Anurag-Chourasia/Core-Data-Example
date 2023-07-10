//
//  IdAndTitle+CoreDataProperties.swift
//  
//
//  Created by Anurag Chourasia on 10/07/23.
//
//

import Foundation
import CoreData


extension IdAndTitle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IdAndTitle> {
        return NSFetchRequest<IdAndTitle>(entityName: "IdAndTitle")
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String?

}
