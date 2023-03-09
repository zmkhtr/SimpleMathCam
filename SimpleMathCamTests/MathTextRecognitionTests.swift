//
//  MathTextRecognitionTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 09/03/23.
//

import XCTest
@testable import SimpleMathCam

class MathTextRecognizer {
    typealias Result = Swift.Result<String, Error>

    private let recognizer: MyTextRecognizer
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    init(recognizer: MyTextRecognizer) {
        self.recognizer = recognizer
    }
    
    func extract(image: UIImage, completion: @escaping (MathTextRecognizer.Result) -> Void) {
        recognizer.process(image: image) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(mathText):
                completion(.success(mathText))
            case .failure:
                completion(.failure(Error.invalidData))
            }
        }
    }
}

class MyTextRecognizer {
    typealias Result = Swift.Result<String, Error>
    
    private var messages = [(image: UIImage, completion: (MyTextRecognizer.Result) -> Void)]()

    var requestedImage: [UIImage] {
        return messages.compactMap { $0.image }
    }
    
    func process(image: UIImage, completion: @escaping (MyTextRecognizer.Result) -> Void) {
        messages.append((image, completion))
    }
    
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with mathText: String, at index: Int = 0) {
        messages[index].completion(.success(mathText))
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
        
        expect(sut, with: anyImage(), toCompleteWith: .failure(.invalidData)) {
            let recognizerError = NSError(domain: "Recognizer Error", code: 0)
            recognizer.complete(with: recognizerError)
        }
        
    }
    
    func test_extract_deliversStringOnTextRecognitionSuccess() {
        let (sut, recognizer) = makeSUT()
        let expected = "2+3"
        
        expect(sut, with: anyImage(), toCompleteWith: .success(expected)) {
            recognizer.complete(with: expected)
        }
    }
    
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MathTextRecognizer, recognizer: MyTextRecognizer) {
        let recognizer = MyTextRecognizer()
        let sut = MathTextRecognizer(recognizer: recognizer)
        
        trackForMemoryLeaks(recognizer, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, recognizer)
    }
    
    
    private func expect(_ sut: MathTextRecognizer, with image: UIImage, toCompleteWith expectedResult: MathTextRecognizer.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.extract(image: image) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
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
