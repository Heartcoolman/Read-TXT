import Foundation
import SwiftData

@Model
final class Bookmark {
    @Attribute(.unique) var id: UUID
    var book: Book?
    var position: Int // Character offset
    var chapterTitle: String?
    var excerpt: String // Preview text
    var note: String?
    var type: BookmarkType
    var createdDate: Date
    var color: String? // Hex color for highlights
    
    init(
        id: UUID = UUID(),
        book: Book? = nil,
        position: Int,
        chapterTitle: String? = nil,
        excerpt: String,
        note: String? = nil,
        type: BookmarkType = .bookmark,
        color: String? = nil
    ) {
        self.id = id
        self.book = book
        self.position = position
        self.chapterTitle = chapterTitle
        self.excerpt = excerpt
        self.note = note
        self.type = type
        self.createdDate = Date()
        self.color = color
    }
}

enum BookmarkType: String, Codable {
    case bookmark
    case highlight
    case note
}

