import Foundation

class ChapterDetector {
    
    // MARK: - Chapter Patterns
    private static let chapterPatterns = [
        // 中文模式
        "^第[0-9零一二三四五六七八九十百千万]+章.*$",
        "^第[0-9零一二三四五六七八九十百千万]+节.*$",
        "^第[0-9零一二三四五六七八九十百千万]+回.*$",
        "^第[0-9零一二三四五六七八九十百千万]+卷.*$",
        "^第[0-9零一二三四五六七八九十百千万]+部.*$",
        "^第[0-9零一二三四五六七八九十百千万]+集.*$",
        "^卷[0-9零一二三四五六七八九十百千万]+.*$",
        "^[0-9零一二三四五六七八九十百千万]+、.*$",
        
        // 英文/数字模式
        "^Chapter\\s+[0-9]+.*$",
        "^CHAPTER\\s+[0-9]+.*$",
        "^Section\\s+[0-9]+.*$",
        "^Part\\s+[0-9]+.*$",
        "^[0-9]+\\.\\s+.+$",
        "^[0-9]+\\s+.+$",
        
        // 特殊标记
        "^【.*】$",
        "^\\[.*\\]$",
        "^==+.*==+$",
        "^--+.*--+$",
    ]
    
    // MARK: - Detect Chapters
    static func detectChapters(text: String) -> [Chapter] {
        var chapters: [Chapter] = []
        
        // 性能优化：限制检查的行数（只检查前10000行）
        let lines = text.components(separatedBy: "\n")
        let linesToCheck = min(lines.count, 10000)
        
        var currentPosition = 0
        var lastChapterStart = 0
        var lastChapterTitle = "开始"
        
        for index in 0..<lines.count {
            let line = lines[index]
            
            // 只在前10000行检查章节模式，提高性能
            if index < linesToCheck {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Check if this line matches any chapter pattern
                if let title = matchChapterPattern(line: trimmedLine) {
                    // Save previous chapter
                    if !chapters.isEmpty || index > 0 {
                        chapters.append(Chapter(
                            title: lastChapterTitle,
                            startPosition: lastChapterStart,
                            endPosition: currentPosition,
                            level: 1
                        ))
                    }
                    
                    // Start new chapter
                    lastChapterTitle = title
                    lastChapterStart = currentPosition
                }
            }
            
            currentPosition += line.count + 1 // +1 for newline
        }
        
        // Add final chapter
        chapters.append(Chapter(
            title: lastChapterTitle,
            startPosition: lastChapterStart,
            endPosition: text.count,
            level: 1
        ))
        
        // If no chapters detected or only one chapter, create automatic chapters
        if chapters.count <= 1 {
            chapters = createAutomaticChapters(text: text)
        }
        
        return chapters
    }
    
    // MARK: - Match Chapter Pattern
    private static func matchChapterPattern(line: String) -> String? {
        // Skip very short or very long lines
        if line.count < 2 || line.count > 100 {
            return nil
        }
        
        for pattern in chapterPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(line.startIndex..<line.endIndex, in: line)
                if regex.firstMatch(in: line, options: [], range: range) != nil {
                    return line
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Create Automatic Chapters
    private static func createAutomaticChapters(text: String, chapterSize: Int = 5000) -> [Chapter] {
        var chapters: [Chapter] = []
        let totalLength = text.count
        var currentPosition = 0
        var chapterNumber = 1
        
        while currentPosition < totalLength {
            let startPosition = currentPosition
            let targetEnd = min(currentPosition + chapterSize, totalLength)
            
            // Try to find a paragraph break near the target position
            var endPosition = targetEnd
            if targetEnd < totalLength {
                let startIndex = text.index(text.startIndex, offsetBy: max(0, targetEnd - 500))
                let endIndex = text.index(text.startIndex, offsetBy: min(totalLength, targetEnd + 500))
                let searchRange = startIndex..<endIndex
                
                if let range = text[searchRange].range(of: "\n\n") {
                    endPosition = text.distance(from: text.startIndex, to: range.upperBound)
                }
            } else {
                endPosition = totalLength
            }
            
            chapters.append(Chapter(
                title: "第 \(chapterNumber) 部分",
                startPosition: startPosition,
                endPosition: endPosition,
                level: 1
            ))
            
            currentPosition = endPosition
            chapterNumber += 1
        }
        
        return chapters
    }
    
    // MARK: - Find Chapter at Position
    static func findChapter(at position: Int, in chapters: [Chapter]) -> Chapter? {
        return chapters.first { chapter in
            position >= chapter.startPosition && position < chapter.endPosition
        }
    }
    
    // MARK: - Get Chapter Index
    static func getChapterIndex(at position: Int, in chapters: [Chapter]) -> Int {
        for (index, chapter) in chapters.enumerated() {
            if position >= chapter.startPosition && position < chapter.endPosition {
                return index
            }
        }
        return 0
    }
}

