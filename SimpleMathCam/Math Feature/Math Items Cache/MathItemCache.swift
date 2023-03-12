//
//  MathItemCache.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 12/03/23.
//

import Foundation

public protocol MathItemCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(to store: MathItemsStore, _ math: MathItem, completion: @escaping (Result) -> Void)
}
