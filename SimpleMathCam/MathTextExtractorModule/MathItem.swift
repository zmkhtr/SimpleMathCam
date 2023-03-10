//
//  MathItem.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation

struct MathItem: Hashable {
    let id: UUID
    let question: String
    let answer: String
    
    init(id: UUID, question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}
