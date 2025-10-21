import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Save Book
    @MainActor
    func saveBook(_ book: Book, to modelContext: ModelContext) {
        modelContext.insert(book)
        try? modelContext.save()
    }
    
    // MARK: - Update Reading Progress
    @MainActor
    func updateProgress(
        for book: Book,
        position: Int,
        chapter: Int,
        percentage: Double,
        in modelContext: ModelContext
    ) {
        if let progress = book.progress {
            progress.currentPosition = position
            progress.currentChapter = chapter
            progress.percentage = percentage
            progress.lastReadDate = Date()
        } else {
            let newProgress = ReadingProgress(
                book: book,
                currentPosition: position,
                currentChapter: chapter,
                percentage: percentage
            )
            modelContext.insert(newProgress)
            book.progress = newProgress
        }
        
        book.lastReadDate = Date()
        try? modelContext.save()
    }
    
    // MARK: - Add Bookmark
    @MainActor
    func addBookmark(
        for book: Book,
        position: Int,
        chapterTitle: String?,
        excerpt: String,
        note: String?,
        type: BookmarkType,
        color: String?,
        in modelContext: ModelContext
    ) {
        let bookmark = Bookmark(
            book: book,
            position: position,
            chapterTitle: chapterTitle,
            excerpt: excerpt,
            note: note,
            type: type,
            color: color
        )
        
        modelContext.insert(bookmark)
        try? modelContext.save()
    }
    
    // MARK: - Delete Bookmark
    @MainActor
    func deleteBookmark(_ bookmark: Bookmark, from modelContext: ModelContext) {
        modelContext.delete(bookmark)
        try? modelContext.save()
    }
    
    // MARK: - Get Recent Books
    @MainActor
    func getRecentBooks(limit: Int = 10, from modelContext: ModelContext) -> [Book] {
        let descriptor = FetchDescriptor<Book>(
            sortBy: [SortDescriptor(\.lastReadDate, order: .reverse)]
        )
        
        do {
            let allBooks = try modelContext.fetch(descriptor)
            return Array(allBooks.prefix(limit))
        } catch {
            print("Failed to fetch recent books: \(error)")
            return []
        }
    }
    
    // MARK: - Save WebDAV Account
    @MainActor
    func saveWebDAVAccount(_ account: WebDAVAccount, password: String, to modelContext: ModelContext) throws {
        modelContext.insert(account)
        try modelContext.save()
        
        // Save password to keychain
        try WebDAVCredentialManager.shared.saveCredentials(
            accountID: account.id,
            username: account.username,
            password: password
        )
    }
    
    // MARK: - Delete WebDAV Account
    @MainActor
    func deleteWebDAVAccount(_ account: WebDAVAccount, from modelContext: ModelContext) throws {
        // Delete from keychain
        try WebDAVCredentialManager.shared.deleteCredentials(accountID: account.id)
        
        // Delete from database
        modelContext.delete(account)
        try modelContext.save()
    }
    
    // MARK: - Save Encoding Preference
    func saveEncodingPreference(bookID: UUID, encoding: String) {
        UserDefaults.standard.set(encoding, forKey: "encoding_\(bookID.uuidString)")
    }
    
    // MARK: - Get Encoding Preference
    func getEncodingPreference(bookID: UUID) -> String? {
        return UserDefaults.standard.string(forKey: "encoding_\(bookID.uuidString)")
    }
}

