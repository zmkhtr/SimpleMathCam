//
//  CoreDataMathItemStore.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 11/03/23.
//

import Foundation
import CoreData

public final class CoreDataMathItemStore {
    private static let modelName = "Math"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataMathItemStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataMathItemStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(modelName: "GameDetail", model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

extension CoreDataMathItemStore: MathItemsStore {
    public func insert(_ math: MathItem, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            if let existingObject = try? CDMathItem.first(with: math.id, in: context) {
                context.delete(existingObject)
            }
            completion(Result {
                CDMathItem.item(from: math, in: context)
                try context.save()
            })
        }
    }
    
    public func getAllData(completion: @escaping (AllResult) -> Void) {
        perform { context in
            completion(Result {
                try CDMathItem.getAllData(in: context)?.map({
                    MathItem(
                        id: $0.id,
                        question: $0.question,
                        answer: $0.answer)
                })
            })
        }
    }
}
