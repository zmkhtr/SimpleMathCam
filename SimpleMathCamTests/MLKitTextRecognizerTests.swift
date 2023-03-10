//
//  MLKitTextRecognizerTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 10/03/23.
//

import XCTest
import MLKit
@testable import SimpleMathCam

class MLKitTextRecognizerTests: XCTestCase  {
    
    func test_process_performImageRecognizer() {
        let expectedString = "as3+3kjc"
        let inputImage = imageWith(name: expectedString)!
        
        expect(makeSUT(), with: inputImage, toCompleteWith: .success(expectedString))
    }
    
    func test_process_performImageRecognizer_returnErrorWhenImageDoesNotHaveText() {
        expect(makeSUT(), with: imageWith(name: "")!, toCompleteWith: .failure(MLKitTextRecognizer.Error.textNotFound))
    }
    
    func test_process_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let recognizer = TextRecognizer.textRecognizer()
        var sut: MLKitTextRecognizer? = MLKitTextRecognizer(recognizer: recognizer)

        var capturedResults = [MyTextRecognizer.Result]()
        sut?.process(image: imageWith(name: "")!, completion: { capturedResults.append($0) })

        sut = nil

        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func makeSUT() -> MLKitTextRecognizer {
        let recognizer = TextRecognizer.textRecognizer()
        let sut = MLKitTextRecognizer(recognizer: recognizer)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: MLKitTextRecognizer, with image: UIImage, toCompleteWith expectedResult: MyTextRecognizer.Result, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.process(image: image) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as MLKitTextRecognizer.Error), .failure(expectedError as MLKitTextRecognizer.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func imageWith(name: String?) -> UIImage? {
         let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
         let nameLabel = UILabel(frame: frame)
         nameLabel.textAlignment = .center
         nameLabel.backgroundColor = .black
         nameLabel.textColor = .white
         nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
         nameLabel.text = name
         UIGraphicsBeginImageContext(frame.size)
          if let currentContext = UIGraphicsGetCurrentContext() {
             nameLabel.layer.render(in: currentContext)
             let nameImage = UIGraphicsGetImageFromCurrentImageContext()
             return nameImage
          }
          return nil
    }

}
