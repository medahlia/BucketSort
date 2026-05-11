import XCTest
//@testable import BucketSort


final class BucketSortTests: XCTestCase {

    let defaultBucketCount = numberOfBuckets(for: 5)
    let defaultThreadCount = 4

    // MARK: - Sequential

    func testSequentialBucketSort() {
        let array = [5, 1, 8, 3, 2]
        let result = sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))
        XCTAssertEqual(result, [1, 2, 3, 5, 8])
    }

    func testSequentialEmptyArray() {
        let array: [Int] = []
        XCTAssertEqual(sequentialBucketSort(array, bucketCount: 1), [])
    }

    func testSequentialSingleElement() {
        let array = [42]
        XCTAssertEqual(sequentialBucketSort(array, bucketCount: 1), [42])
    }

    func testSequentialAlreadySorted() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count)), array)
    }

    func testSequentialReverseSorted() {
        let array = [9, 7, 5, 3, 1]
        XCTAssertEqual(sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count)), [1, 3, 5, 7, 9])
    }

    // MARK: - Parallel (різна к-сть потоків)

    func testParallelBucketSort2Threads() {
        let array = [10, 7, 2, 15, 1]
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 2)
        XCTAssertEqual(result, [1, 2, 7, 10, 15])
    }

    func testParallelBucketSort4Threads() {
        let array = [10, 7, 2, 15, 1]
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4)
        XCTAssertEqual(result, [1, 2, 7, 10, 15])
    }

    func testParallelBucketSort8Threads() {
        let array = [10, 7, 2, 15, 1]
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 8)
        XCTAssertEqual(result, [1, 2, 7, 10, 15])
    }

    func testParallelEmptyArray() {
        let array: [Int] = []
        XCTAssertEqual(parallelBucketSort(array, bucketCount: 1, threadCount: 4), [])
    }

    func testParallelSingleElement() {
        let array = [42]
        XCTAssertEqual(parallelBucketSort(array, bucketCount: 1, threadCount: 4), [42])
    }

    func testParallelAlreadySorted() {
        let array = [1, 2, 3, 4, 5]
        XCTAssertEqual(parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4), array)
    }

    func testParallelReverseSorted() {
        let array = [9, 7, 5, 3, 1]
        XCTAssertEqual(parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4), [1, 3, 5, 7, 9])
    }

    // MARK: - Різна к-сть бакетів

    func testSqrtNBuckets() {
        let array = generateRandomArray(size: 10_000)
        let buckets = numberOfBuckets(for: array.count)
        let seq = sequentialBucketSort(array, bucketCount: buckets)
        let par = parallelBucketSort(array, bucketCount: buckets, threadCount: 4)
        XCTAssertEqual(seq, par)
    }

    func testDoubleSqrtNBuckets() {
        let array = generateRandomArray(size: 10_000)
        let buckets = numberOfBucketsDouble(for: array.count)
        let seq = sequentialBucketSort(array, bucketCount: buckets)
        let par = parallelBucketSort(array, bucketCount: buckets, threadCount: 4)
        XCTAssertEqual(seq, par)
    }

    // MARK: - Seq == Par для всіх комбінацій

    func testSeqEqualParAllCombinations() {
        let array = generateRandomArray(size: 10_000)

        for threadCount in [2, 4, 8] {
            for bucketCount in [numberOfBuckets(for: array.count), numberOfBucketsDouble(for: array.count)] {
                let seq = sequentialBucketSort(array, bucketCount: bucketCount)
                let par = parallelBucketSort(array, bucketCount: bucketCount, threadCount: threadCount)
                XCTAssertEqual(seq, par, "Провалено: threads=\(threadCount), buckets=\(bucketCount)")
            }
        }
    }
}
