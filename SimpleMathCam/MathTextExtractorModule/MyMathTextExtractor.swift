//
//  MyMathTextExtractor.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import UIKit

protocol MyMathTextExtractor {
    typealias Result = Swift.Result<MathItem, Error>

    func extract(image: UIImage, completion: @escaping (MathTextExtractor.Result) -> Void)
}
