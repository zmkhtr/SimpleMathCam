//
//  CDMathItem.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 11/03/23.
//

import Foundation
import CoreData

@objc(CDMathItem)
class CDMathItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var answer: String
    @NSManaged var question: String
}

extension CDMathItem {
    
    static func first(with id: UUID, in context: NSManagedObjectContext) throws -> CDMathItem? {
        let request = NSFetchRequest<CDMathItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(CDMathItem.id), id])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func getAllData(in context: NSManagedObjectContext) throws -> [CDMathItem]? {
        let request = NSFetchRequest<CDMathItem>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
    
    static func item(from math: MathItem, in context: NSManagedObjectContext) {
        let managed = CDMathItem(context: context)
        managed.id = math.id
        managed.answer = math.answer
        managed.question = math.question
    }
}
