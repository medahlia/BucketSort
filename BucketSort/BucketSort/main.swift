import Foundation
import Dispatch

func measureTime(message: String, operation: () -> Void) -> Double {
    let startTime = DispatchTime.now()
    operation()
    let endTime = DispatchTime.now()
    let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
    print("\(message): \(String(format: "%.3f", elapsedTime)) с")
    return elapsedTime
}

// MARK: - Bucket strategy labels
 
enum BucketStrategy: CaseIterable {
    case sqrtN
    case doubleSqrtN
 
    func label() -> String {
        switch self {
        case .sqrtN:       return "√N"
        case .doubleSqrtN: return "2·√N"
        }
    }
 
    func count(for size: Int) -> Int {
        switch self {
        case .sqrtN:       return numberOfBuckets(for: size)
        case .doubleSqrtN: return numberOfBucketsDouble(for: size)
        }
    }
}
 
// MARK: - Result type
 
struct BenchmarkResult {
    let size: Int
    let bucketStrategy: String
    let bucketCount: Int
    let threadCount: Int
    let seqAvg: Double
    let parAvg: Double
    var speedup: Double { seqAvg / parAvg }
}
 
// MARK: - Benchmark
 
func benchmark(
    size: Int,
    bucketStrategy: BucketStrategy,
    threadCount: Int,
    runs: Int = 5
) -> BenchmarkResult {
 
    let bucketCount = bucketStrategy.count(for: size)
    let array = generateRandomArray(size: size)
 
    print("\n┌─────────────────────────────────────────────────────────")
    print("│ Розмір: \(size)  │  Бакети: \(bucketCount) (\(bucketStrategy.label()))  │  Потоки: \(threadCount)")
    print("├─────────────────────────────────────────────────────────")
 
    // Warm-up
    print("  [Warm-up]")
    //for w in 1...3 {
        _ = sequentialBucketSort(array, bucketCount: bucketCount)
        _ = parallelBucketSort(array, bucketCount: bucketCount, threadCount: threadCount)
    //    print("  Warm-up \(w)/3 done")
    print("  Warm-up done")
    //}
    print("  ─────────────────────────────────")
 
    var seqTimes: [Double] = []
    var parTimes: [Double] = []
 
    for i in 1...runs {
        print("  [Run \(i)/\(runs)]")
        let seqTime = measureTime(message: "Seq run \(i)") {
            _ = sequentialBucketSort(array, bucketCount: bucketCount)
        }
        let parTime = measureTime(message: "Par run \(i)") {
            _ = parallelBucketSort(array, bucketCount: bucketCount, threadCount: threadCount)
        }
        seqTimes.append(seqTime)
        parTimes.append(parTime)
    }
 
    let avgSeq = seqTimes.reduce(0, +) / Double(runs)
    let avgPar = parTimes.reduce(0, +) / Double(runs)
 
    print("  ─────────────────────────────────")
    print("  Середнє Seq: \(String(format: "%.3f", avgSeq)) с")
    print("  Середнє Par: \(String(format: "%.3f", avgPar)) с")
    print("  Прискорення: \(String(format: "%.2f", avgSeq / avgPar))x")
    print("└─────────────────────────────────────────────────────────")
 
    return BenchmarkResult(
        size: size,
        bucketStrategy: bucketStrategy.label(),
        bucketCount: bucketCount,
        threadCount: threadCount,
        seqAvg: avgSeq,
        parAvg: avgPar
    )
}


// MARK: - Table output
 
func printTable(results: [BenchmarkResult]) {
    let header = "| Розмір      | Бакети      | К-ть бакетів | Потоки | Seq (с) | Par (с) | Прискорення |"
    let divider = String(repeating: "-", count: header.count)
    print("\n\(divider)")
    print(header)
    print(divider)
    for r in results {
        let size    = "\(r.size)".padding(toLength: 11, withPad: " ", startingAt: 0)
        let strat   = r.bucketStrategy.padding(toLength: 11, withPad: " ", startingAt: 0)
        let buckets = "\(r.bucketCount)".padding(toLength: 12, withPad: " ", startingAt: 0)
        let threads = "\(r.threadCount)".padding(toLength: 6, withPad: " ", startingAt: 0)
        let seq     = String(format: "%.3f", r.seqAvg).padding(toLength: 7, withPad: " ", startingAt: 0)
        let par     = String(format: "%.3f", r.parAvg).padding(toLength: 7, withPad: " ", startingAt: 0)
        let spd     = String(format: "%.2f", r.speedup) + "x"
        print("| \(size) | \(strat) | \(buckets) | \(threads) | \(seq) | \(par) | \(spd.padding(toLength: 11, withPad: " ", startingAt: 0)) |")
    }
    print(divider)
}


// MARK: - Run
 
//let sizes       = [1_000_000, 5_000_000, 10_000_000, 20_000_000, 30_000_000]
let sizes       = [10_000_000]
let threadCounts = [2, 4, 8, 16]
let strategies  = BucketStrategy.allCases
 
var allResults: [BenchmarkResult] = []
 
for size in sizes {
    for strategy in strategies {
        for threads in threadCounts {
            let result = benchmark(
                size: size,
                bucketStrategy: strategy,
                threadCount: threads
            )
            allResults.append(result)
        }
    }
}
 
printTable(results: allResults)


/*
 
 === Розмір: 1 000 000, Комірок: 1000 ===
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
 
 
 
 === Розмір: 20 000 000, Комірок: 4472 ===
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

 === Розмір: 30 000 000, Комірок: 5477 ===
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
