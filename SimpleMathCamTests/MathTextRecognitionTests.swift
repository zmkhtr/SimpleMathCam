//
//  MathTextRecognitionTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 09/03/23.
//

import XCTest
@testable import SimpleMathCam

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

protocol MyMathTextExtractor {
    typealias Result = Swift.Result<MathItem, Error>

    func extract(image: UIImage, completion: @escaping (MathTextExtractor.Result) -> Void)
}

class MathTextExtractor: MyMathTextExtractor {
    
    typealias Result = MyMathTextExtractor.Result

    private let recognizer: MyTextRecognizer
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    init(recognizer: MyTextRecognizer) {
        self.recognizer = recognizer
    }
    
    func extract(image: UIImage, completion: @escaping (Result) -> Void) {
        recognizer.process(image: image) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(text):
                completion(MathTextExtractor.map(extractedText: text))
            case .failure:
                completion(.failure(Error.invalidData))
            }
        }
    }
    
    static func map(extractedText: String) -> Result {
        do {
            let items = try MathItemMapper.map(text: extractedText)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

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
        
        let question = "\(numbersFront.joined())\(mathSymbol)\(numbersEnd.joined())"
        var answer = ""
        
        if question.isEmpty {
            throw MathTextExtractor.Error.invalidData
        }
        
        if question.contains(".") {
            let expn = NSExpression(format: "\(numbersFront.joined())\(mathSymbol)\(numbersEnd.joined())")
            if let answerDouble = expn.expressionValue(with: nil, context: nil) as? Double {
                answer = "\(answerDouble.clean)"
            } else {
                throw MathTextExtractor.Error.invalidData
            }
        } else {
            let expn = NSExpression(format: "\(numbersFront.joined()).0\(mathSymbol)\(numbersEnd.joined()).0")
            
            if let answerDouble = expn.expressionValue(with: nil, context: nil) as? Double {
                answer = "\(answerDouble.clean)"
            } else {
                throw MathTextExtractor.Error.invalidData
            }
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
            print("SDSJ")
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

class MathTextRecognitionTests: XCTestCase {

    func test_init_doesNotRequestStringFromImage() {
        let (_, recognizer) = makeSUT()
        
        XCTAssertTrue(recognizer.requestedImage.isEmpty)
    }
    
    func test_extract_requestStringFromImage() {
        let image = anyImage()
        let (sut, recognizer) = makeSUT()
        
        sut.extract(image: image) { _ in }
        
        XCTAssertEqual(recognizer.requestedImage, [image])
    }
    
    func test_extract_requestStringFromImageTwice() {
        let image = anyImage()
        let (sut, recognizer) = makeSUT()
        
        sut.extract(image: image) { _ in }
        sut.extract(image: image) { _ in }
        
        XCTAssertEqual(recognizer.requestedImage, [image, image])
    }
    
    func test_extract_deliversErrorOnTextRecognitionError() {
        let (sut, recognizer) = makeSUT()
        
        expect(sut, with: anyImage(), toCompleteWith: failure(.invalidData)) {
            let recognizerError = NSError(domain: "Recognizer Error", code: 0)
            recognizer.complete(with: recognizerError)
        }
        
    }
    
    func test_extract_deliversStringOnTextRecognitionSuccess() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "2+3"
        let expectedMathItem = createMathItem(question: "2+3", answer: "5")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversCorretResultOnTextRecognitionSuccessWithRandomStringThatContainsMathSymbol() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "sajh20+34lsdk"
        let expectedMathItem = createMathItem(question: "20+34", answer: "54")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_proceedFirstEquationOnTextRecognitionSuccessWithRandomStringThatContainsMathSymbol() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "x-jksd10x44hhfjbd4\n398*76wskjd\rh234j"
        let expectedMathItem = createMathItem(question: "10*44", answer: "440")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversCorretResultOnTextRecognitionSuccessWithRandomStringThatContainsAddition() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "x-jksd10+44hhfjbd4\n398*76wskjd\rh234j"
        let expectedMathItem = createMathItem(question: "10+44", answer: "54")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversCorretResultOnTextRecognitionSuccessWithRandomStringThatContainsSubtraction() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "x-jksd10-44hhfjbd4\n398*76wskjd\rh234j"
        let expectedMathItem = createMathItem(question: "10-44", answer: "-34")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversCorretResultOnTextRecognitionSuccessWithRandomStringThatContainsDivision() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "x-jksd10,49/3.394hhfjbd4\n398*76wskjd\rh234j"
        let expectedMathItem = createMathItem(question: "10.49/3.394", answer: "3.090748379493223")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversCorretResultOnTextRecognitionSuccessWithRandomStringThatContainsMultiplier() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "x-jksd10x44hhfjbd4\n398*76wskjd\rh234j"
        let expectedMathItem = createMathItem(question: "10*44", answer: "440")
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expectedMathItem)) {
            recognizer.complete(with: detectedString)
        }
    }
    
    func test_extract_deliversErrorOnTextRecognitionSuccessWithRandomStringThatNotContainsMathSymbol() {
        let (sut, recognizer) = makeSUT()
        let detectedString = "tidakAdaMathSymbols"
        
        expect(sut, with: anyImage(), toCompleteWith: failure(.invalidData)) {
            recognizer.complete(with: detectedString)
        }
    }

    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let recognizer = MyTextRecognizerSpy()
        var sut: MathTextExtractor? = MathTextExtractor(recognizer: recognizer)

        var capturedResults = [MathTextExtractor.Result]()
        sut?.extract(image: anyImage()) { capturedResults.append($0) }

        sut = nil
        recognizer.complete(with: "2+3")

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func failure(_ error: MathTextExtractor.Error) -> MathTextExtractor.Result {
        return .failure(error)
    }
    
    private func createMathItem(id: UUID = UUID(), question: String, answer: String) -> MathItem {
        return MathItem(id: id, question: question, answer: answer)
    }
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MathTextExtractor, recognizer: MyTextRecognizerSpy) {
        let recognizer = MyTextRecognizerSpy()
        let sut = MathTextExtractor(recognizer: recognizer)
        
        trackForMemoryLeaks(recognizer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, recognizer)
    }
    
    
    private func expect(_ sut: MathTextExtractor, with image: UIImage, toCompleteWith expectedResult: MathTextExtractor.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.extract(image: image) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems.question, expectedItems.question, file: file, line: line)
                XCTAssertEqual(receivedItems.answer, expectedItems.answer, file: file, line: line)
            case let (.failure(receivedError as MathTextExtractor.Error), .failure(expectedError as MathTextExtractor.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyImage() -> UIImage {
        return UIImage.make(withColor: .red)
    }
}

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
