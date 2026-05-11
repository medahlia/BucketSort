//
//  ArrayGenerator.swift
//  BucketSort
//
//  Created by Home on 11.05.2026.
//

import Foundation


public func generateRandomArray(size: Int) -> [Int] {
    return (0..<size).map { _ in Int.random(in: 0...1_000_000_000) }
}

public func numberOfBuckets(for size: Int) -> Int {
    return Int(Double(size).squareRoot())
}
