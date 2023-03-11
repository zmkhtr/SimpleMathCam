//
//  CodableMathItemsStore.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 11/03/23.
//

import Foundation

public class CodableMathItemsStore: MathItemsStore {
    
    private struct Cache: Codable {
        let math: [CodableMathItem]
        
        var localMath: [MathItem] {
            return math.map { $0.local }
        }
    }
    
    private struct CodableMathItem: Codable {
        private let id: UUID
        private let answer: String
        private let question: String
        
        init(_ math: MathItem) {
            id = math.id
            answer = math.answer
            question = math.question
        }
        
        var local: MathItem {
            return MathItem(id: id, question: question, answer: answer)
        }
    }
    
    public enum InsertError: Error {
        case failed
    }
    
    public enum LoadError: Error {
        case failed
    }
    
    private let queue = DispatchQueue(label: "\(CodableMathItemsStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func getAllData(completion: @escaping (MathItemsStore.AllResult) -> Void) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(cache.localMath))
            } catch {
                completion(.failure(LoadError.failed))
            }
        }
    }
    
    public func insert(_ math: MathItem, completion: @escaping (MathItemsStore.InsertionResult) -> Void) {
        let storeURL = self.storeURL
        self.getAllData { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(savedItems):
                if var items = savedItems {
                    items.append(math)
                    self.insert(items, completion: completion)
                } else {
                    self.insert([math], completion: completion)
                }
            case .failure:
                self.insert([math], completion: completion)
            }
        }
   
    }
    
    private func insert(_ items: [MathItem], completion: @escaping (InsertionResult) -> Void) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(math: items.map(CodableMathItem.init))
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
