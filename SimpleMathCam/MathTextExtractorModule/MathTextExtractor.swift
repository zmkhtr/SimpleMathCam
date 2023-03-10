//
//  MathTextExtractor.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import UIKit

class MathTextExtractor: MyMathTextExtractor {
    
    typealias Result = MyMathTextExtractor.Result

    private let recognizer: MyTextRecognizer
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    init(recognizer: MyTextRecognizer) {
        self.recognizer = recognizer
    }
    
    func extract(image: UIImage, completion: @escaping (Result) -> Void) {
        recognizer.process(image: image) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(text):
                completion(MathTextExtractor.map(extractedText: text))
            case .failure:
                completion(.failure(Error.invalidData))
            }
        }
    }
    
    static func map(extractedText: String) -> Result {
        do {
            let items = try MathItemMapper.map(text: extractedText)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
