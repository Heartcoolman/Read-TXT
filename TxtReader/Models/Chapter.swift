import Foundation

struct Chapter: Identifiable, Equatable {
    let id: UUID
    let title: String
    let startPosition: Int
    let endPosition: Int
    let level: Int // For nested chapters
    
    init(
        id: UUID = UUID(),
        title: String,
        startPosition: Int,
        endPosition: Int,
        level: Int = 1
    ) {
        self.id = id
        self.title = title
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.level = level
    }
}

