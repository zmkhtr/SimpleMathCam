//
//  MathItem.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation

public struct MathItem: Hashable {
    public let id: UUID
    public let question: String
    public let answer: String
    
    public init(id: UUID, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}
