//
//  MathTextExtractorTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 09/03/23.
//

import XCTest
@testable import SimpleMathCam

class MathTextExtractorTests: XCTestCase {

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

