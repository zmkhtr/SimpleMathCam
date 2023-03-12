//
//  MainQueueDispatchDecorator.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 12/03/23.
//

import Foundation
import UIKit

public final class MainQueueDispatchDecorator<T> {

  private(set) public var decoratee: T

  public init(decoratee: T) {
    self.decoratee = decoratee
  }

  public func dispatch(completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }

    completion()
  }
}

extension MainQueueDispatchDecorator: MathItemsLoader where T == MathItemsLoader {
    
    func get(from store: MathItemsStore, completion: @escaping (MathItemsLoader.Result) -> Void) {
        decoratee.get(from: store) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: MyMathTextExtractor where T == MyMathTextExtractor {
    
    func extract(image: UIImage, completion: @escaping (Result<MathItem, Error>) -> Void) {
        
        decoratee.extract(image: image) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: MathItemCache where T == MathItemCache {
    
    public func save(to store: MathItemsStore, _ math: MathItem, completion: @escaping (MathItemCache.Result) -> Void) {
        decoratee.save(to: store, math) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

