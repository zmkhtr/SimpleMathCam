//
//  CoreDataMathItemStoreTests.swift
//  SimpleMathCamTests
//
//  Created by Azam Mukhtar on 11/03/23.
//

import XCTest
@testable import SimpleMathCam

class CoreDataGameDetailStoreTests: XCTestCase {
    
    func test_getAllData_deliverNotFoundWhenEmpty() {
        makeSUT().getAllData { result in
            switch result {
            case let .success(gamesDetail):
                XCTAssertEqual(0, gamesDetail?.count)
            default:
                break
            }
        }
    }
    
    func test_getAllData_deliverAllInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = makeItem()
        let id = UUID()
        let lastStoredData = makeItem(id: id)

        insert(firstStoredData, into: sut)
        insert(lastStoredData, into: sut)
        insert(lastStoredData, into: sut)

        sut.getAllData { result in
            switch result {
            case let .success(gamesDetail):
                XCTAssertNotNil(gamesDetail)
                XCTAssertEqual(2, gamesDetail?.count)
            default:
                break
            }
        }
    }
    
    private func notFound() -> MathItemsStore.AllResult {
        return .success(.none)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataMathItemStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataMathItemStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ math: MathItem, into sut: MathItemsStore, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(math) { result in
            switch result {
            case let .failure(error):
                XCTFail("Failed to save \(math) with error \(error)", file: file, line: line)
                exp.fulfill()

            case .success:
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: UUID = UUID()) -> MathItem {
        return MathItem(id: id, question: "2 + 3", answer: "5")
    }
}
