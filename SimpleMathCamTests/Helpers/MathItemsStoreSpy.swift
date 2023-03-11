//
//  MathItemsStoreSpy.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation
import SimpleMathCam

class MathItemsStoreSpy: MathItemsStore {
    
    enum Message: Equatable {
        case insert(math: MathItem)
        case retrieveAll
    }
    
    private(set) var receivedMessages = [Message]()
    
    private var insertionCompletions = [(MathItemsStore.InsertionResult) -> Void]()
    private var allCompletions = [(MathItemsStore.AllResult) -> Void]()
    

    func insert(_ math: MathItem, completion: @escaping (MathItemsStore.InsertionResult) -> Void) {
        receivedMessages.append(.insert(math: math))
        insertionCompletions.append(completion)
    }
    
    func getAllData(completion: @escaping (MathItemsStore.AllResult) -> Void) {
        receivedMessages.append(.retrieveAll)
        allCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func completeAllRetrieval(with error: Error, at index: Int = 0) {
        allCompletions[index](.failure(error))
    }
    
    func completeAllRetrieval(with game: [MathItem]?, at index: Int = 0) {
        allCompletions[index](.success(game))
    }
}
