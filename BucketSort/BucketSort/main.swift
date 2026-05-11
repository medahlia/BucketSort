//
//  main.swift
//  BucketSort
//
//  Created by Home on 11.05.2026.
//


print("Hello, World!")

// Послідовна Реалізація Сортування Відрами
func sequentialBucketSort(_ array: [Int]) -> [Int] {
    guard !array.isEmpty else { return array }

    let numberOfBuckets = Int(Double(array.count).squareRoot())
    let minValue = array.min()!
    let maxValue = array.max()!

    // Створення відер
    var buckets = [[Int]](repeating: [], count: numberOfBuckets)

    // Розподіл елементів по відрах
    for element in array {
        let bucketIndex = Int(Double(element - minValue) / Double(maxValue - minValue + 1) * Double(numberOfBuckets))
        buckets[bucketIndex].append(element)
    }

    // Сортування кожного відра
    for i in 0..<numberOfBuckets {
        buckets[i].sort()
    }

    // Об'єднання відсортованих відер
    var sortedArray = [Int]()
    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }

    return sortedArray
}

// Паралельна Реалізація Сортування Відрами
import Dispatch

func parallelBucketSort(_ array: [Int]) -> [Int] {
    guard !array.isEmpty else { return array }

    let numberOfBuckets = Int(Double(array.count).squareRoot())
    let minValue = array.min()!
    let maxValue = array.max()!

    var buckets = [[Int]](repeating: [], count: numberOfBuckets)
    let lock = NSLock()

    for element in array {
        let bucketIndex = Int(Double(element - minValue) / Double(maxValue - minValue + 1) * Double(numberOfBuckets))
        lock.lock()
        buckets[bucketIndex].append(element)
        lock.unlock()
    }

    let queue = DispatchQueue.global(qos: .userInitiated)
    let group = DispatchGroup()

    for i in 0..<numberOfBuckets {
        group.enter()
        queue.async {
            buckets[i].sort()
            group.leave()
        }
    }

    group.wait()

    var sortedArray = [Int]()
    for bucket in buckets {
        sortedArray.append(contentsOf: bucket)
    }

    return sortedArray
}

// Код Вимірювання Продуктивності та Обчислення Прискорення
import Foundation

func generateRandomArray(size: Int) -> [Int] {
    return (0..<size).map { _ in Int.random(in: 0...1000) }
}

func measureTime(message: String, operation: () -> Void) -> Double {
    print("Початок вимірювання: \(message)")
    let startTime = DispatchTime.now()
    operation()
    let endTime = DispatchTime.now()
    let elapsedTime = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000_000
    print("Завершення вимірювання: \(message), Час виконання: \(elapsedTime) секунд")
    return elapsedTime
}

let arraySize = 100_000
let randomArray = generateRandomArray(size: arraySize)

let sequentialTime = measureTime(message: "Послідовне сортування відрами") {
    _ = sequentialBucketSort(randomArray)
}

let parallelTime = measureTime(message: "Паралельне сортування відрами") {
    _ = parallelBucketSort(randomArray)
}

let speedup = sequentialTime / parallelTime
print("Прискорення: \(speedup)")
