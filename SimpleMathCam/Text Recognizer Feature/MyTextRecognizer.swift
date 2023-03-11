//
//  MyTextRecognizer.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 09/03/23.
//

import UIKit

public protocol MyTextRecognizer {
    typealias Result = Swift.Result<String, Error>
    
    func process(image: UIImage, completion: @escaping (MyTextRecognizer.Result) -> Void)
}
