//
//  MyTextRecognizerSpy.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 09/03/23.
//

import Foundation
import UIKit

class MyTextRecognizerSpy: MyTextRecognizer {
    
    private var messages = [(image: UIImage, completion: (MyTextRecognizer.Result) -> Void)]()

    var requestedImage: [UIImage] {
        return messages.compactMap { $0.image }
    }
    
    func process(image: UIImage, completion: @escaping (MyTextRecognizer.Result) -> Void) {
        messages.append((image, completion))
    }
    
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with mathText: String, at index: Int = 0) {
        messages[index].completion(.success(mathText))
    }
}
