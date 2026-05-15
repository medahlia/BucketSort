import Foundation


public func generateRandomArray(size: Int) -> [SortableItem] {
    return (0..<size).map { i in
        SortableItem(
            id: Int.random(in: 0...100_000_000_000), // може змінити (?)
            name: "item_\(i)",
            score: Double.random(in: 0...100_000_000_000) //
        )
    }
}

public func numberOfBuckets(for size: Int) -> Int {
    return Int(Double(size).squareRoot())
}

public func numberOfBucketsDouble(for size: Int) -> Int {
    return Int(2.0 * Double(size).squareRoot())
}
