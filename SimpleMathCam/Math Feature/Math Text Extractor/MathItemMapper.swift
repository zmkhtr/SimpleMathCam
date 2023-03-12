//
//  MathItemMapper.swift
//  SimpleMathCam
//
//  Created by Azam Mukhtar on 10/03/23.
//

import Foundation

class MathItemMapper {
    
    static func map(text: String) throws -> MathItem {
        
        var isMathSymbol = false
        var lastIndex = 0
        var mathSymbol = ""
        var numbersFront: [String] = []
        var numbersEnd: [String] = []

        let textArray = (Array(text))
        
        for (index, value) in text.enumerated() {
            
            let mathSymbolChecker = self.isMathSymbolCharacter(for: value)
            if textArray.indices.contains(index - 1) && textArray.indices.contains(index + 1) {
                if let _ = Int("\(Array(text)[index - 1])"),
                   let _ = Int("\(Array(text)[index + 1])"),
                   mathSymbolChecker.isMathSymbol && index > 0 {
                    isMathSymbol = true
                    mathSymbol = "\(mathSymbolChecker.symbol)"
                }
            }
            
            if value == "," || value == "." {
                if let _ = Int("\(Array(text)[index - 1])"),
                   let _ = Int("\(Array(text)[index + 1])") {
                    if !numbersFront.contains(".") {
                        numbersFront.append(".")
                    } else if !numbersEnd.contains(".") {
                        lastIndex = 0
                        numbersEnd.append(".")
                    }
                }
            }
            
            if let _ = Int("\(value)"), !isMathSymbol {
                numbersFront.append("\(value)")
            } else if textArray.indices.contains(index + 1) {
                if let _ = Int("\(value)"),
                   let _ = Int("\(Array(text)[index + 1])"),
                   !isMathSymbol {
                    numbersFront.append("\(value)")
                }
            }

            if let _ = Int("\(value)"),
               isMathSymbol {
                
                let range = index - lastIndex
                if lastIndex == 0 || range == 1{
                    lastIndex = index
                    numbersEnd.append("\(value)")
                }
            }
        }
        
        var question = "\(numbersFront.joined())\(mathSymbol)\(numbersEnd.joined())"
        var answer = ""

        if let firstNumbers = Double(numbersFront.joined()),
            let secondNumbers = Double(numbersEnd.joined()) {
            question = "\(firstNumbers)\(mathSymbol)\(secondNumbers)"
        } else {
            throw MathTextExtractor.Error.invalidData
        }
        
        if question.isEmpty {
            throw MathTextExtractor.Error.invalidData
        }
        
        if !mathSymbol.isEmpty {
            let expn = NSExpression(format: "\(numbersFront.joined())\(mathSymbol)\(numbersEnd.joined())")
            if let answerDouble = expn.expressionValue(with: nil, context: nil) as? Double {
                answer = "\(answerDouble)"
            } else {
                throw MathTextExtractor.Error.invalidData
            }
        } else {
            throw MathTextExtractor.Error.invalidData
        }
       
        
        return MathItem(id: UUID(), question: question, answer: answer)
    }
    
    private static func isMathSymbolCharacter(for char: Character) -> (isMathSymbol: Bool, symbol: String) {
        if char == "x" || char == "X" {
            return (true, "*")
        }
        if char == ":" || char == "/" {
            return (true, "/")
        }
        if char == "-" {
            return (true, "-")
        }
        if char.isMathSymbol {
            return (true, "\(char)")
        }
        return (false, "\(char)")
    }
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
