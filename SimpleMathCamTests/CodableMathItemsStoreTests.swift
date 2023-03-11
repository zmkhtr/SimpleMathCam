//
//  CodableMathItemsStoreTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 11/03/23.
//

import XCTest
@testable import SimpleMathCam

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .success(.none))
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let item = makeItem()

        insert(item, to: sut)

        expect(sut, toRetrieve: .success([item]))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let item = makeItem()

        insert(item, to: sut)

        expect(sut, toRetrieveTwice: .success([item]))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(CodableMathItemsStore.LoadError.failed))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(CodableMathItemsStore.LoadError.failed))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let item = makeItem()


        let insertionError = insert(item, to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
        expect(sut, toRetrieve:.success(.none))
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        let item = makeItem()
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(item) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.insert(item) { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2], "Expected side-effects to run serially but operations finished in the wrong order")
    }

    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> MathItemsStore {
        let sut = CodableMathItemsStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ item: MathItem, to sut: MathItemsStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        sut.insert(item) { results in
            switch results {
            case let .failure(error):
                insertionError = error
            default:
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    private func expect(_ sut: MathItemsStore, toRetrieveTwice expectedResult: MathItemsStore.AllResult, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieve: expectedResult, file: file, line: line)
            expect(sut, toRetrieve: expectedResult, file: file, line: line)
        }
    
    private func expect(_ sut: MathItemsStore, toRetrieve expectedResult: MathItemsStore.AllResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.getAllData { retrievedResult in
            switch (expectedResult, retrievedResult)  {
            case let (.success(expected), .success(retrieved)):
                XCTAssertEqual(expected, retrieved, file: file, line: line)
            case let (.failure(expectedError as CodableMathItemsStore.LoadError), .failure(receivedError as CodableMathItemsStore.LoadError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
   
            default:
                XCTFail("Expected result \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func makeItem(id: UUID = UUID()) -> MathItem {
        return MathItem(id: id, question: "2 + 3", answer: "5")
    }
}
