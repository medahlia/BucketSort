import XCTest


final class BucketSortTests: XCTestCase {

    // Хелпер для створення тестових об'єктів
    private func items(_ ids: [Int]) -> [SortableItem] {
        return ids.map { SortableItem(id: $0, name: "item_\($0)", score: Double($0)) }
    }

    // Хелпер для отримання ids з результату
    private func ids(_ items: [SortableItem]) -> [Int] {
        return items.map { $0.id }
    }

    // MARK: - Sequential

    func testSequentialBucketSort() {
        let array = items([5, 1, 8, 3, 2])
        let result = sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))
        XCTAssertEqual(ids(result), [1, 2, 3, 5, 8])
    }

    func testSequentialEmptyArray() {
        let array: [SortableItem] = []
        XCTAssertEqual(sequentialBucketSort(array, bucketCount: 1).count, 0)
    }

    func testSequentialSingleElement() {
        let array = items([42])
        XCTAssertEqual(ids(sequentialBucketSort(array, bucketCount: 1)), [42])
    }

    func testSequentialAlreadySorted() {
        let array = items([1, 2, 3, 4, 5])
        XCTAssertEqual(ids(sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))), [1, 2, 3, 4, 5])
    }

    func testSequentialReverseSorted() {
        let array = items([9, 7, 5, 3, 1])
        XCTAssertEqual(ids(sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))), [1, 3, 5, 7, 9])
    }

    // MARK: - Parallel

    func testParallelBucketSort2Threads() {
        let array = items([10, 7, 2, 15, 1])
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 2)
        XCTAssertEqual(ids(result), [1, 2, 7, 10, 15])
    }

    func testParallelBucketSort4Threads() {
        let array = items([10, 7, 2, 15, 1])
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4)
        XCTAssertEqual(ids(result), [1, 2, 7, 10, 15])
    }

    func testParallelBucketSort8Threads() {
        let array = generateRandomArray(size: 10_000)
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 8)
        XCTAssertEqual(ids(result), ids(sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))))
    }

    func testParallelEmptyArray() {
        let array: [SortableItem] = []
        XCTAssertEqual(parallelBucketSort(array, bucketCount: 1, threadCount: 4).count, 0)
    }

    func testParallelAlreadySorted() {
        let array = items([1, 2, 3, 4, 5])
        XCTAssertEqual(ids(parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4)), [1, 2, 3, 4, 5])
    }

    func testParallelReverseSorted() {
        let array = items([9, 7, 5, 3, 1])
        XCTAssertEqual(ids(parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4)), [1, 3, 5, 7, 9])
    }

    // MARK: - Bucket strategies

    func testSqrtNBuckets() {
        let array = generateRandomArray(size: 10_000)
        let buckets = numberOfBuckets(for: array.count)
        XCTAssertEqual(
            ids(sequentialBucketSort(array, bucketCount: buckets)),
            ids(parallelBucketSort(array, bucketCount: buckets, threadCount: 4))
        )
    }

    func testDoubleSqrtNBuckets() {
        let array = generateRandomArray(size: 10_000)
        let buckets = numberOfBucketsDouble(for: array.count)
        XCTAssertEqual(
            ids(sequentialBucketSort(array, bucketCount: buckets)),
            ids(parallelBucketSort(array, bucketCount: buckets, threadCount: 4))
        )
    }

    func testSeqEqualParAllCombinations() {
        let array = generateRandomArray(size: 10_000)
        for threadCount in [2, 4, 8] {
            for bucketCount in [numberOfBuckets(for: array.count), numberOfBucketsDouble(for: array.count)] {
                XCTAssertEqual(
                    ids(sequentialBucketSort(array, bucketCount: bucketCount)),
                    ids(parallelBucketSort(array, bucketCount: bucketCount, threadCount: threadCount)),
                    "Провалено: threads=\(threadCount), buckets=\(bucketCount)"
                )
            }
        }
    }

    // MARK: - Перевірка що об'єкти не втрачаються

    func testObjectsNotLost() {
        let array = generateRandomArray(size: 1_000)
        let result = parallelBucketSort(array, bucketCount: numberOfBuckets(for: array.count), threadCount: 4)
        XCTAssertEqual(result.count, array.count)
    }

    func testObjectFieldsPreserved() {
        let array = items([3, 1, 2])
        let result = sequentialBucketSort(array, bucketCount: numberOfBuckets(for: array.count))
        XCTAssertEqual(result[0].name, "item_1")
        XCTAssertEqual(result[1].name, "item_2")
        XCTAssertEqual(result[2].name, "item_3")
    }
}
