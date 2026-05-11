import Foundation
import Dispatch

//func generateRandomArray(size: Int) -> [Int] {
//    return (0..<size).map { _ in Int.random(in: 0...1_000_000_000) }
//}
//
//func numberOfBuckets(for size: Int) -> Int {
//    return Int(Double(size).squareRoot())
//}

//func sequentialBucketSort(_ array: [Int]) -> [Int] {
//    guard !array.isEmpty else { return array }
//    let numberOfBuckets = numberOfBuckets(for: array.count)
//    let minValue = array.min()!
//    let maxValue = array.max()!
//    var buckets: [[Int]] = Array(repeating: [], count: numberOfBuckets)
//    
//    for element in array {
//        let bucketIndex = Int(Double(element - minValue) / Double(maxValue - minValue + 1) * Double(numberOfBuckets))
//        buckets[bucketIndex].append(element)
//    }
//    
//    for i in 0..<numberOfBuckets {
//        buckets[i].sort()
//    }
//    
//    var sortedArray: [Int] = []
//    for bucket in buckets {
//        sortedArray.append(contentsOf: bucket)
//    }
//    return sortedArray
//}

//func parallelBucketSort(_ array: [Int]) -> [Int] {
//    guard !array.isEmpty else { return array }
//    let numberOfBuckets = numberOfBuckets(for: array.count)
//    let minValue = array.min()!
//    let maxValue = array.max()!
//    var buckets: [[Int]] = Array(repeating: [], count: numberOfBuckets)
//    let lock = NSLock()
//    
//    for element in array {
//        let bucketIndex = Int(Double(element - minValue) / Double(maxValue - minValue + 1) * Double(numberOfBuckets))
//        lock.lock()
//        buckets[bucketIndex].append(element)
//        lock.unlock()
//    }
//    
//    let queue = DispatchQueue.global(qos: .userInitiated)
//    let group = DispatchGroup()
//    
//    for i in 0..<numberOfBuckets {
//        group.enter()
//        queue.async {
//            buckets[i].sort()
//            group.leave()
//        }
//    }
//    group.wait()
//    
//    var sortedArray: [Int] = []
//    for bucket in buckets {
//        sortedArray.append(contentsOf: bucket)
//    }
//    return sortedArray
//}

func benchmark(size: Int, runs: Int = 5) -> (Int, Double, Double) {
    let numBuckets = numberOfBuckets(for: size)
    let array = generateRandomArray(size: size)
    print("\n=== Розмір: \(size), Комірок: \(numBuckets) ===")
    
    // Warm-up
    for _ in 0..<3 {
        _ = sequentialBucketSort(array)
        _ = parallelBucketSort(array)
    }
    
    var seqTimes: [Double] = []
    var parTimes: [Double] = []
    
    for i in 1...runs {
//        спочатку йде паралельний, потім послідовний
        let parTime = measureTime(message: "Par run \(i)") { _ = parallelBucketSort(array) }
        let seqTime = measureTime(message: "Seq run \(i)") { _ = sequentialBucketSort(array) }
        
        seqTimes.append(seqTime)
        parTimes.append(parTime)
    }
    
    let avgSeq = seqTimes.reduce(0, +) / Double(runs)
    let avgPar = parTimes.reduce(0, +) / Double(runs)
    let speedup = avgSeq / avgPar
    
    return (numBuckets, avgSeq, avgPar)
}

func measureTime(message: String, operation: () -> Void) -> Double {
    let startTime = DispatchTime.now()
    operation()
    let endTime = DispatchTime.now()
    let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
    print("\(message): \(String(format: "%.3f", elapsedTime)) с")
    return elapsedTime
}

func printTable(results: [(size: Int, buckets: Int, seqAvg: Double, parAvg: Double, speedup: Double)]) {
    print("\n| Розмір | Комірок | Seq (с) | Par (с) | Прискорення |")
    print("|--------|---------|---------|---------|-------------|")
    for r in results {
        print("| \(r.size) | \(r.buckets) | \(String(format: "%.3f", r.seqAvg)) | \(String(format: "%.3f", r.parAvg)) | \(String(format: "%.2f", r.speedup))x |")
    }
}

var allResults: [(size: Int, buckets: Int, seqAvg: Double, parAvg: Double, speedup: Double)] = []

//let sizes = [1_000_000, 5_000_000, 10_000_000]
let sizes = [20_000_000, 30_000_000]
for size in sizes {
    let (buckets, seqAvg, parAvg) = benchmark(size: size)
    let speedup = seqAvg / parAvg
    allResults.append((size, buckets, seqAvg, parAvg, speedup))
}

printTable(results: allResults)


/*
 
 === Розмір: 1000000, Комірок: 1000 ===
 Seq run 1: 1.621 с
 Par run 1: 0.859 с
 Seq run 2: 1.466 с
 Par run 2: 0.781 с
 Seq run 3: 1.489 с
 Par run 3: 0.826 с
 Seq run 4: 1.503 с
 Par run 4: 0.819 с
 Seq run 5: 1.529 с
 Par run 5: 0.711 с

 === Розмір: 5000000, Комірок: 2236 ===
 Seq run 1: 5.614 с
 Par run 1: 2.436 с
 Seq run 2: 5.732 с
 Par run 2: 2.189 с
 Seq run 3: 5.571 с
 Par run 3: 2.502 с
 Seq run 4: 5.645 с
 Par run 4: 2.514 с
 Seq run 5: 5.586 с
 Par run 5: 2.138 с

 === Розмір: 10000000, Комірок: 3162 ===
 Seq run 1: 15.066 с
 Par run 1: 5.197 с
 Seq run 2: 14.458 с
 Par run 2: 5.948 с
 Seq run 3: 14.073 с
 Par run 3: 5.966 с
 Seq run 4: 14.810 с
 Par run 4: 5.725 с
 Seq run 5: 13.937 с
 Par run 5: 5.739 с

 | Розмір | Комірок | Seq (с) | Par (с) | Прискорення |
 |--------|---------|---------|---------|-------------|
 | 1000000 | 1000 | 1.522 | 0.799 | 1.90x |
 | 5000000 | 2236 | 5.630 | 2.356 | 2.39x |
 | 10000000 | 3162 | 14.469 | 5.715 | 2.53x |
 Program ended with exit code: 0
 
 
 
 === Розмір: 20000000, Комірок: 4472 ===
 Seq run 1: 22.764 с
 Par run 1: 8.234 с
 Seq run 2: 22.939 с
 Par run 2: 9.288 с
 Seq run 3: 23.605 с
 Par run 3: 9.603 с
 Seq run 4: 24.096 с
 Par run 4: 8.939 с
 Seq run 5: 23.680 с
 Par run 5: 8.247 с

 === Розмір: 30000000, Комірок: 5477 ===
 Seq run 1: 42.154 с
 Par run 1: 13.689 с
 Seq run 2: 39.766 с
 Par run 2: 13.741 с
 Seq run 3: 41.755 с
 Par run 3: 13.321 с
 Seq run 4: 41.351 с
 Par run 4: 16.812 с
 Seq run 5: 40.760 с
 Par run 5: 15.430 с

 | Розмір | Комірок | Seq (с) | Par (с) | Прискорення |
 |--------|---------|---------|---------|-------------|
 | 20000000 | 4472 | 23.417 | 8.862 | 2.64x |
 | 30000000 | 5477 | 41.157 | 14.598 | 2.82x |
 Program ended with exit code: 0
 */
