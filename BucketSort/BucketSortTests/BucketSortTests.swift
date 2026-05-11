import XCTest
@testable import BucketSort


final class BucketSortTests: XCTestCase {
    
    func testSequentialBucketSort() {
        let array = [5, 1, 8, 3, 2]
        let result = sequentialBucketSort(array)
        XCTAssertEqual(result, [1, 2, 3, 5, 8])
    }
    
    func testParallelBucketSort() {
        let array = [10, 7, 2, 15, 1]
        let result = parallelBucketSort(array)
        XCTAssertEqual(result, [1, 2, 7, 10, 15])
    }
    
    func testEmptyArray() {
        let array: [Int] = []
        XCTAssertEqual(sequentialBucketSort(array), [])
        XCTAssertEqual(parallelBucketSort(array), [])
    }
    
    func testSingleElementArray() {
        let array = [42]
        XCTAssertEqual(sequentialBucketSort(array), [42])
        XCTAssertEqual(parallelBucketSort(array), [42])
    }
    
    func testAlreadySortedArray() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(sequentialBucketSort(array), array)
        XCTAssertEqual(parallelBucketSort(array), array)
    }
    
    func testReverseSortedArray() {
        let array = [9, 7, 5, 3, 1]
        let expected = [1, 3, 5, 7, 9]
        XCTAssertEqual(sequentialBucketSort(array), expected)
        XCTAssertEqual(parallelBucketSort(array), expected)
    }
    
    func testRandomArraysEquality() {
        let array = generateRandomArray(size: 10_000)
        let seq = sequentialBucketSort(array)
        let par = parallelBucketSort(array)
        XCTAssertEqual(seq, par)
    }
}
