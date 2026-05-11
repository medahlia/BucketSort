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
 

struct BenchmarkResult {
    let size: Int
    let bucketStrategy: String
    let bucketCount: Int
    let threadCount: Int
    let seqAvg: Double
    let parAvg: Double
    var speedup: Double { seqAvg / parAvg }
}
 

func benchmark(size: Int, bucketStrategy: BucketStrategy, threadCount: Int, runs: Int = 10) -> BenchmarkResult {
 
    let bucketCount = bucketStrategy.count(for: size)
    let array = generateRandomArray(size: size)
 
    print("\n┌─────────────────────────────────────────────────────────")
    print("│ Розмір: \(size)  │  Бакети: \(bucketCount) (\(bucketStrategy.label()))  │  Потоки: \(threadCount)")
    print("├─────────────────────────────────────────────────────────")
 
    print("  [Warm-up]")
    _ = sequentialBucketSort(array, bucketCount: bucketCount)
    _ = parallelBucketSort(array, bucketCount: bucketCount, threadCount: threadCount)
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


func printTable(results: [BenchmarkResult]) {
    let header = "| Розмір      | Бакети      | К-ть бакетів | Потоки | Seq (с) | Par (с) | Прискорення |"
    let divider = String(repeating: "-", count: header.count)
    print("\n\(divider)")
    print(header)
    print(divider)
    for r in results {
        let size = "\(r.size)".padding(toLength: 11, withPad: " ", startingAt: 0)
        let strat = r.bucketStrategy.padding(toLength: 11, withPad: " ", startingAt: 0)
        let buckets = "\(r.bucketCount)".padding(toLength: 12, withPad: " ", startingAt: 0)
        let threads = "\(r.threadCount)".padding(toLength: 6, withPad: " ", startingAt: 0)
        let seq = String(format: "%.3f", r.seqAvg).padding(toLength: 7, withPad: " ", startingAt: 0)
        let par = String(format: "%.3f", r.parAvg).padding(toLength: 7, withPad: " ", startingAt: 0)
        let spd = String(format: "%.2f", r.speedup) + "x"
        print("| \(size) | \(strat) | \(buckets) | \(threads) | \(seq) | \(par) | \(spd.padding(toLength: 11, withPad: " ", startingAt: 0)) |")
    }
    print(divider)
}

let sizes = [1_000_000, 5_000_000, 10_000_000, 20_000_000]
let threadCounts = [2, 4, 8, 16]
let strategies = BucketStrategy.allCases
 
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
