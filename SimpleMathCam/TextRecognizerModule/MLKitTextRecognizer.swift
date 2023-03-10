//
//  MLKitTextRecognizer.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation
import MLKit

class MLKitTextRecognizer: MyTextRecognizer {
    
    typealias Result = MyTextRecognizer.Result

    private let recognizer: TextRecognizer
    
    public enum Error: Swift.Error {
        case textNotFound
    }
    
    init(recognizer: TextRecognizer) {
        self.recognizer = recognizer
    }
    
    func process(image: UIImage, completion: @escaping (Result) -> Void) {
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        recognizer.process(visionImage) { [weak self] text, error in
            guard self != nil else { return }
            if let text, !text.text.isEmpty {
                completion(.success(text.text))
            } else {
                completion(.failure(Error.textNotFound))
            }
        }
    }
}
