//
//  LocalMathItemLoaderTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 10/03/23.
//

import XCTest
@testable import SimpleMathCam

class LocalMathItemLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        XCTAssertTrue(storeSpy().receivedMessages.isEmpty)
    }

    func test_loadMathItems_failsOnStoreError() {
        let sut = makeSUT()
        let store = storeSpy()

        expectGetAll(sut, store: store, toCompleteWith: .failure(LocalMathItemsLoader.LoadError.failed), when: {
            let retrievalError = anyNSError()
            store.completeAllRetrieval(with: retrievalError)
        })
    }

    func test_loadMathItems_deliversEmptyItemsOnNotFound() {
        let sut = makeSUT()
        let store = storeSpy()
        
        expectGetAll(sut, store: store, toCompleteWith: .success([]), when: {
            store.completeAllRetrieval(with: [])
        })
    }

    func test_loadMathItems_deliversStoredDataOnFoundData() {
        let sut = makeSUT()
        let store = storeSpy()
        let foundData1 = makeItem()
        let foundData2 = makeItem()


        expectGetAll(sut, store: store, toCompleteWith: .success([foundData1, foundData2]), when: {
            store.completeAllRetrieval(with: [foundData1, foundData2], at: 0)
        })
    }

    func test_loadMathItemsL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = MathItemsStoreSpy()
        var sut: LocalMathItemsLoader? = LocalMathItemsLoader()

        var received = [LocalMathItemsLoader.Result]()
        sut?.get(from: store) { received.append($0) }

        sut = nil
        store.completeAllRetrieval(with: [makeItem()])

        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> LocalMathItemsLoader {
        let sut = LocalMathItemsLoader()
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func storeSpy() -> MathItemsStoreSpy {
       return MathItemsStoreSpy()
    }
    
    private func expectGetAll(_ sut: LocalMathItemsLoader, store: MathItemsStoreSpy, toCompleteWith expectedResult: MathItemsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.get(from: store) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case (.failure(let receivedError as LocalMathItemsLoader.LoadError), .failure(let expectedError as LocalMathItemsLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem() -> MathItem {
        return MathItem(id: UUID(), question: "2 + 3", answer: "5")
    }
}


