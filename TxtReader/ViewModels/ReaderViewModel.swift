import Foundation
import SwiftUI
import SwiftData
import AVFoundation

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var book: Book
    @Published var fullText: String = ""
    @Published var chapters: [Chapter] = []
    @Published var pages: [Page] = []
    @Published var currentPageIndex: Int = 0
    @Published var currentChapterIndex: Int = 0
    @Published var searchResults: [SearchResult] = []
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    @Published var showEncodingPicker: Bool = false
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    // TTS
    @Published var isSpeaking: Bool = false
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    private var modelContext: ModelContext?
    private var readingStartTime: Date?
    
    init(book: Book) {
        self.book = book
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Load Book
    func loadBook(settings: ReaderSettings) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Read file
            let fileURL = URL(fileURLWithPath: book.filePath)
            let data = try Data(contentsOf: fileURL)
            
            // Get encoding
            let encodingName = book.encoding
            let encoding = getEncoding(from: encodingName)
            
            // Decode text
            fullText = try TextDecoder.decode(data: data, encoding: encoding)
            
            // Detect chapters
            chapters = ChapterDetector.detectChapters(text: fullText)
            
            // Paginate if in paged mode
            if settings.readingMode == "paged" {
                await paginateText(settings: settings)
            }
            
            // Restore reading progress
            if let progress = book.progress {
                currentPageIndex = 0
                if !pages.isEmpty {
                    currentPageIndex = PaginationEngine.findPageIndex(at: progress.currentPosition, in: pages)
                }
                currentChapterIndex = ChapterDetector.getChapterIndex(at: progress.currentPosition, in: chapters)
            }
            
            readingStartTime = Date()
            isLoading = false
        } catch {
            errorMessage = "加载书籍失败: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Paginate Text
    func paginateText(settings: ReaderSettings) async {
        let font = settings.fontName == "System" 
            ? UIFont.systemFont(ofSize: settings.fontSize)
            : UIFont(name: settings.fontName, size: settings.fontSize) ?? UIFont.systemFont(ofSize: settings.fontSize)
        
        // Calculate page size (subtract padding)
        let screenSize = UIScreen.main.bounds.size
        let pageSize = CGSize(
            width: screenSize.width - settings.horizontalPadding * 2,
            height: screenSize.height - settings.verticalPadding * 2
        )
        
        pages = await Task.detached {
            PaginationEngine.paginate(
                text: self.fullText,
                pageSize: pageSize,
                font: font,
                lineSpacing: settings.lineSpacing,
                paragraphSpacing: settings.paragraphSpacing
            )
        }.value
    }
    
    // MARK: - Navigate
    func nextPage() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            updateProgress()
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
            updateProgress()
        }
    }
    
    func goToPage(_ index: Int) {
        if index >= 0 && index < pages.count {
            currentPageIndex = index
            updateProgress()
        }
    }
    
    func goToChapter(_ index: Int) {
        if index >= 0 && index < chapters.count {
            let chapter = chapters[index]
            currentChapterIndex = index
            
            if !pages.isEmpty {
                currentPageIndex = PaginationEngine.findPageIndex(at: chapter.startPosition, in: pages)
            }
            
            updateProgress()
        }
    }
    
    // MARK: - Search
    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        searchQuery = query
        searchResults = []
        
        Task {
            let results = await performSearch(query: query)
            searchResults = results
            isSearching = false
        }
    }
    
    private func performSearch(query: String) async -> [SearchResult] {
        return await Task.detached {
            var results: [SearchResult] = []
            let lowercasedQuery = query.lowercased()
            
            let lines = self.fullText.components(separatedBy: .newlines)
            var position = 0
            
            for (lineIndex, line) in lines.enumerated() {
                if line.lowercased().contains(lowercasedQuery) {
                    let chapterIndex = ChapterDetector.getChapterIndex(at: position, in: self.chapters)
                    let chapterTitle = chapterIndex < self.chapters.count 
                        ? self.chapters[chapterIndex].title 
                        : "未知章节"
                    
                    results.append(SearchResult(
                        id: UUID(),
                        position: position,
                        lineNumber: lineIndex,
                        chapterTitle: chapterTitle,
                        excerpt: line,
                        matchedText: query
                    ))
                }
                
                position += line.count + 1
            }
            
            return results
        }.value
    }
    
    // MARK: - Update Progress
    func updateProgress() {
        guard let context = modelContext else { return }
        
        let position: Int
        if pages.isEmpty {
            position = 0
        } else if currentPageIndex < pages.count {
            position = pages[currentPageIndex].startPosition
        } else {
            position = 0
        }
        
        let percentage = fullText.isEmpty ? 0 : Double(position) / Double(fullText.count)
        
        // Update reading time
        var readingTime: TimeInterval = 0
        if let progress = book.progress {
            readingTime = progress.readingTime
        }
        
        if let startTime = readingStartTime {
            readingTime += Date().timeIntervalSince(startTime)
            readingStartTime = Date()
        }
        
        DataManager.shared.updateProgress(
            for: book,
            position: position,
            chapter: currentChapterIndex,
            percentage: percentage,
            in: context
        )
    }
    
    // MARK: - Bookmarks
    func addBookmark(note: String? = nil, type: BookmarkType = .bookmark, color: String? = nil) {
        guard let context = modelContext else { return }
        
        let position: Int
        let excerpt: String
        
        if pages.isEmpty {
            position = 0
            excerpt = String(fullText.prefix(100))
        } else if currentPageIndex < pages.count {
            let page = pages[currentPageIndex]
            position = page.startPosition
            excerpt = String(page.text.prefix(100))
        } else {
            position = 0
            excerpt = ""
        }
        
        let chapterTitle = currentChapterIndex < chapters.count 
            ? chapters[currentChapterIndex].title 
            : nil
        
        DataManager.shared.addBookmark(
            for: book,
            position: position,
            chapterTitle: chapterTitle,
            excerpt: excerpt,
            note: note,
            type: type,
            color: color,
            in: context
        )
    }
    
    // MARK: - TTS
    func toggleSpeech() {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            speakCurrentPage()
        }
    }
    
    private func speakCurrentPage() {
        guard currentPageIndex < pages.count else { return }
        
        let text = pages[currentPageIndex].text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }
    
    // MARK: - Change Encoding
    func changeEncoding(_ encoding: String.Encoding, encodingName: String) async {
        do {
            let fileURL = URL(fileURLWithPath: book.filePath)
            let data = try Data(contentsOf: fileURL)
            
            fullText = try TextDecoder.decode(data: data, encoding: encoding)
            
            book.encoding = encodingName
            if let context = modelContext {
                try context.save()
            }
            
            DataManager.shared.saveEncodingPreference(bookID: book.id, encoding: encodingName)
            
            showEncodingPicker = false
        } catch {
            errorMessage = "编码转换失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper
    private func getEncoding(from name: String) -> String.Encoding {
        for (encoding, encodingName) in EncodingDetector.supportedEncodings {
            if encodingName == name {
                return encoding
            }
        }
        return .utf8
    }
    
    // MARK: - Progress Info
    var readingProgress: Double {
        guard !pages.isEmpty, currentPageIndex < pages.count else { return 0 }
        return Double(currentPageIndex + 1) / Double(pages.count)
    }
    
    var estimatedTimeRemaining: TimeInterval {
        guard !pages.isEmpty, currentPageIndex < pages.count else { return 0 }
        
        let remainingPages = pages.count - currentPageIndex
        let remainingCharacters = pages[currentPageIndex...].reduce(0) { $0 + $1.text.count }
        
        return PaginationEngine.estimateReadingTime(characterCount: remainingCharacters)
    }
}

// MARK: - Search Result
struct SearchResult: Identifiable {
    let id: UUID
    let position: Int
    let lineNumber: Int
    let chapterTitle: String
    let excerpt: String
    let matchedText: String
}

