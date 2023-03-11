//
//  MathItemsStore.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation

public protocol MathItemsStore {
    typealias AllResult = Swift.Result<[MathItem]?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(_ math: MathItem, completion: @escaping (InsertionResult) -> Void)
    func getAllData(completion: @escaping (AllResult) -> Void)
}
