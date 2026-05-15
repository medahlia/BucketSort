import Foundation


public struct SortableItem {
    public let id: Int
    public let name: String
    public let score: Double

    public init(id: Int, name: String, score: Double) {
        self.id = id
        self.name = name
        self.score = score
    }
}
