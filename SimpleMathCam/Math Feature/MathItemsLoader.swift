//
//  MathItemsLoader.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation

protocol MathItemsLoader {
    typealias Result = Swift.Result<[MathItem], Error>
    
    func get(from store: MathItemsStore, completion: @escaping (Result) -> Void)
}
