import Foundation
import SwiftData

@Model
final class Book {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String?
    var filePath: String
    var fileSize: Int64
    var encoding: String
    var source: BookSource
    var lastReadDate: Date?
    var addedDate: Date
    var totalCharacters: Int
    
    // WebDAV specific
    var webdavURL: String?
    var webdavAccountID: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \ReadingProgress.book)
    var progress: ReadingProgress?
    
    @Relationship(deleteRule: .cascade, inverse: \Bookmark.book)
    var bookmarks: [Bookmark]?
    
    init(
        id: UUID = UUID(),
        title: String,
        author: String? = nil,
        filePath: String,
        fileSize: Int64,
        encoding: String = "UTF-8",
        source: BookSource,
        webdavURL: String? = nil,
        webdavAccountID: UUID? = nil,
        totalCharacters: Int = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.filePath = filePath
        self.fileSize = fileSize
        self.encoding = encoding
        self.source = source
        self.webdavURL = webdavURL
        self.webdavAccountID = webdavAccountID
        self.addedDate = Date()
        self.totalCharacters = totalCharacters
    }
}

enum BookSource: String, Codable {
    case webdav
    case local
}

