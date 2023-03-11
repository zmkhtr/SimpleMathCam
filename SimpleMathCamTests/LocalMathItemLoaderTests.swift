//
//  LocalMathItemLoaderTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 10/03/23.
//

import XCTest
@testable import SimpleMathCam

class LocalMathItemsLoader: MathItemsLoader {
    private let store: MathItemsStore
    
    typealias Result = MathItemsLoader.Result
    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    public init(store: MathItemsStore) {
        self.store = store
    }
    
    func get(completion: @escaping (Result) -> Void) {
        store.getAllData { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(math):
                if let math = math {
                    completion(.success(math))
                } else {
                    completion(.failure(LoadError.notFound))
                }
            case .failure:
                completion(.failure(LoadError.failed))
            }
        }
    }
}

class LocalMathItemLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadMathItems_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expectGetAll(sut, toCompleteWith: .failure(LocalMathItemsLoader.LoadError.failed), when: {
            let retrievalError = anyNSError()
            store.completeAllRetrieval(with: retrievalError)
        })
    }

    func test_loadMathItems_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        expectGetAll(sut, toCompleteWith: .failure(LocalMathItemsLoader.LoadError.notFound), when: {
            store.completeAllRetrieval(with: .none)
        })
    }

    func test_loadMathItems_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData1 = makeItem()
        let foundData2 = makeItem()


        expectGetAll(sut, toCompleteWith: .success([foundData1, foundData2]), when: {
            store.completeAllRetrieval(with: [foundData1, foundData2], at: 0)
        })
    }

    func test_loadMathItemsL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = MathItemsStoreSpy()
        var sut: LocalMathItemsLoader? = LocalMathItemsLoader(store: store)

        var received = [LocalMathItemsLoader.Result]()
        sut?.get { received.append($0) }

        sut = nil
        store.completeAllRetrieval(with: [makeItem()])

        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalMathItemsLoader, store: MathItemsStoreSpy) {
        let store = MathItemsStoreSpy()
        let sut = LocalMathItemsLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
//    private func failed() -> LocalMathItemsLoader.Result {
//        return .failure(LocalMathItemsLoader.LoadError.failed)
//    }
//
//    private func notFound() -> LocalMathItemsLoader.Result {
//        return .failure(LocalMathItemsLoader.LoadError.notFound)
//    }
    
//    private func never(file: StaticString = #file, line: UInt = #line) {
//        XCTFail("Expected no no invocations", file: file, line: line)
//    }
//
//    private func expect(_ sut: LocalGameDetailLoader, toCompleteWith expectedResult: GameDetailLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
//        let exp = expectation(description: "Wait for load completion")
//
//        sut.get(for: 234) { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedData), .success(expectedData)):
//                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
//
//            case (.failure(let receivedError as LocalGameDetailLoader.LoadError), .failure(let expectedError as LocalGameDetailLoader.LoadError)):
//                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
//
//            default:
//                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
//            }
//
//            exp.fulfill()
//        }
//        action()
//        wait(for: [exp], timeout: 1.0)
//    }
//
    private func expectGetAll(_ sut: LocalMathItemsLoader, toCompleteWith expectedResult: MathItemsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.get { receivedResult in
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
//
//    private func anyID() -> Int {
//        return Int.random(in: 0..<300)
//    }
//
//    private func makeItem() -> GameDetailItem {
//        return GameDetailItem(id: anyID(), title: "GTA", releaseDate: "2013-09-17", rating: 3.5, image: anyURL(), description: "any description", played: 93, developers: "Rockstart", isFavorite: false)
//    }
}


