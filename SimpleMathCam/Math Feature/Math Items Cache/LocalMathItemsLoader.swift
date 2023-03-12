//
//  LocalMathItemsLoader.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 11/03/23.
//

import Foundation

class LocalMathItemsLoader: MathItemsLoader {
    var store: MathItemsStore
    
    typealias Result = MathItemsLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    public init(store: MathItemsStore) {
        self.store = store
    }
    
    func get(completion: @escaping (Result) -> Void) {
        store.getAllData { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(math):
                if let math = math {
                    completion(.success(math))
                } else {
                    completion(.failure(LoadError.notFound))
                }
            case .failure:
                completion(.failure(LoadError.failed))
            }
        }
    }
}

extension LocalMathItemsLoader: MathItemCache {
    public enum SaveError: Error {
        case failed
    }
    
    func save(_ math: MathItem, completion: @escaping (MathItemCache.Result) -> Void) {
        store.insert(math) { [weak self] result in
            guard self != nil else { return }
            
            completion(result.mapError { _ in SaveError.failed } )
        }
    }
}
