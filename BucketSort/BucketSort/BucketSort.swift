import Foundation
import Dispatch


public func sequentialBucketSort(_ array: [SortableItem], bucketCount: Int) -> [SortableItem] {
    guard !array.isEmpty else { return array }

    let minValue = array.min(by: { $0.id < $1.id })!.id
    let maxValue = array.max(by: { $0.id < $1.id })!.id

    var buckets: [[SortableItem]] = Array(repeating: [], count: bucketCount)

    for element in array {
        let bucketIndex = Int(
            Double(element.id - minValue) /
            Double(maxValue - minValue + 1) *
            Double(bucketCount)
        )

        buckets[bucketIndex].append(element)
    }

    for i in 0..<bucketCount {
        buckets[i].sort(by: { $0.id < $1.id })
    }

    var sortedArray: [SortableItem] = []

    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }

    return sortedArray
}


public func parallelBucketSort(_ array: [SortableItem], bucketCount: Int, threadCount: Int) -> [SortableItem] {
    guard !array.isEmpty else { return array }
    
    let minValue = array.min(by: { $0.id < $1.id })!.id
    let maxValue = array.max(by: { $0.id < $1.id })!.id
    
    var localBuckets: [[[SortableItem]]] = Array(
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
                Double(element.id - minValue) /
                Double(maxValue - minValue + 1) *
                Double(bucketCount)
            )
            localBuckets[t][bucketIndex].append(element)
        }
    }
    var buckets: [[SortableItem]] = Array(repeating: [], count: bucketCount)
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
                buffer[i].sort(by: { $0.id < $1.id })
            }
        }
    }
    var sortedArray: [SortableItem] = []
    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }
    return sortedArray
}
