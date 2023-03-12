//
//  MathTextExtractorCacheDecorator.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 12/03/23.
//

import UIKit

class MathTextExtractorCacheDecorator: MyMathTextExtractor {

    private let decoratee: MyMathTextExtractor
    private let cache: MathItemCache
    
    init(decoratee: MyMathTextExtractor, cache: MathItemCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func extract(image: UIImage, completion: @escaping (Result<MathItem, Error>) -> Void) {
        decoratee.extract(image: image) { [weak self] result in
            completion(result.map { math in
                self?.cache.saveIgnoringResult(math)
                return math
            })
        }
    }
}

private extension MathItemCache {
    func saveIgnoringResult(_ math: MathItem) {
        save(math) { _ in }
    }
}
