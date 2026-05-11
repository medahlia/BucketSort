import Foundation
import Dispatch


public func sequentialBucketSort(_ array: [Int], bucketCount: Int) -> [Int] {
    guard !array.isEmpty else { return array }

    let minValue = array.min()!
    let maxValue = array.max()!

    var buckets: [[Int]] = Array(repeating: [], count: bucketCount)

    for element in array {
        let bucketIndex = Int(
            Double(element - minValue) /
            Double(maxValue - minValue + 1) *
            Double(bucketCount)
        )

        buckets[bucketIndex].append(element)
    }

    for i in 0..<bucketCount {
        buckets[i].sort()
    }

    var sortedArray: [Int] = []

    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }

    return sortedArray
}


public func parallelBucketSort(_ array: [Int], bucketCount: Int, threadCount: Int) -> [Int] {
    guard !array.isEmpty else { return array }
    let minValue = array.min()!
    let maxValue = array.max()!
    var localBuckets: [[[Int]]] = Array(
        repeating: Array(repeating: [], count: bucketCount),
        count: threadCount
    )
    let chunkSize = max(1, array.count / threadCount)
    DispatchQueue.concurrentPerform(iterations: threadCount) { t in
        let start = t * chunkSize
        let end = (t == threadCount - 1) ? array.count : start + chunkSize
        for i in start..<end {
            let element = array[i]
            let bucketIndex = Int(
                Double(element - minValue) /
                Double(maxValue - minValue + 1) *
                Double(bucketCount)
            )
            localBuckets[t][bucketIndex].append(element)
        }
    }
    var buckets: [[Int]] = Array(repeating: [], count: bucketCount)
    for t in 0..<threadCount {
        for b in 0..<bucketCount {
            buckets[b].append(contentsOf: localBuckets[t][b])
        }
    }
    let bucketChunkSize = max(1, (bucketCount + threadCount - 1) / threadCount)
    buckets.withUnsafeMutableBufferPointer { buffer in
        DispatchQueue.concurrentPerform(iterations: threadCount) { t in
            let start = t * bucketChunkSize
            let end = min(start + bucketChunkSize, bucketCount)
            guard start < end else { return }
            for i in start..<end {
                buffer[i].sort()
            }
        }
    }
    var sortedArray: [Int] = []
    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }
    return sortedArray
}
