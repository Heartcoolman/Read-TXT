import Foundation
import SwiftData

@Model
final class ReadingProgress {
    @Attribute(.unique) var id: UUID
    var book: Book?
    var currentPosition: Int // Character offset
    var currentChapter: Int
    var percentage: Double
    var lastReadDate: Date
    var readingTime: TimeInterval // Total reading time in seconds
    
    init(
        id: UUID = UUID(),
        book: Book? = nil,
        currentPosition: Int = 0,
        currentChapter: Int = 0,
        percentage: Double = 0.0,
        readingTime: TimeInterval = 0
    ) {
        self.id = id
        self.book = book
        self.currentPosition = currentPosition
        self.currentChapter = currentChapter
        self.percentage = percentage
        self.lastReadDate = Date()
        self.readingTime = readingTime
    }
}

