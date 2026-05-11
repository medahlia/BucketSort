//
//  BucketSort.swift
//  BucketSort
//
//  Created by Home on 11.05.2026.
//

import Foundation
import Dispatch


func sequentialBucketSort(_ array: [Int]) -> [Int] {
    guard !array.isEmpty else { return array }

    let bucketCount = numberOfBuckets(for: array.count)
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

func parallelBucketSort(_ array: [Int]) -> [Int] {
    guard !array.isEmpty else { return array }

    let bucketCount = numberOfBuckets(for: array.count)
    let minValue = array.min()!
    let maxValue = array.max()!

    var buckets: [[Int]] = Array(repeating: [], count: bucketCount)

    let lock = NSLock()

    for element in array {
        let bucketIndex = Int(
            Double(element - minValue) /
            Double(maxValue - minValue + 1) *
            Double(bucketCount)
        )

        lock.lock()
        buckets[bucketIndex].append(element)
        lock.unlock()
    }

    let queue = DispatchQueue.global(qos: .userInitiated)
    let group = DispatchGroup()

    for i in 0..<bucketCount {
        group.enter()

        queue.async {
            buckets[i].sort()
            group.leave()
        }
    }

    group.wait()

    var sortedArray: [Int] = []

    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }

    return sortedArray
}
