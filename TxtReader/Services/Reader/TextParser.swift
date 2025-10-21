import Foundation

class TextParser {
    
    // MARK: - Parse Text
    static func parse(text: String) -> ParsedText {
        let normalized = normalizeText(text)
        let paragraphs = splitIntoParagraphs(normalized)
        
        return ParsedText(
            originalText: text,
            normalizedText: normalized,
            paragraphs: paragraphs,
            characterCount: normalized.count,
            wordCount: estimateWordCount(normalized)
        )
    }
    
    // MARK: - Normalize Text
    private static func normalizeText(_ text: String) -> String {
        var result = text
        
        // Remove multiple consecutive blank lines (keep max 2)
        result = result.replacingOccurrences(
            of: "\n\n\n+",
            with: "\n\n",
            options: .regularExpression
        )
        
        // Trim whitespace at start and end
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    // MARK: - Split Into Paragraphs
    private static func splitIntoParagraphs(_ text: String) -> [Paragraph] {
        var paragraphs: [Paragraph] = []
        var currentPosition = 0
        
        let lines = text.components(separatedBy: "\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if !trimmedLine.isEmpty {
                let startPosition = currentPosition
                let endPosition = currentPosition + trimmedLine.count
                
                paragraphs.append(Paragraph(
                    id: UUID(),
                    text: trimmedLine,
                    startPosition: startPosition,
                    endPosition: endPosition
                ))
            }
            
            // Move position (including newline)
            currentPosition += line.count + 1
        }
        
        return paragraphs
    }
    
    // MARK: - Word Count Estimation
    private static func estimateWordCount(_ text: String) -> Int {
        // For CJK characters, each character is a word
        // For other scripts, count by whitespace
        var wordCount = 0
        
        for character in text {
            if isCJKCharacter(character) {
                wordCount += 1
            }
        }
        
        // Count non-CJK words
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && !$0.allSatisfy(isCJKCharacter) }
        
        wordCount += words.count
        
        return wordCount
    }
    
    private static func isCJKCharacter(_ character: Character) -> Bool {
        guard let scalar = character.unicodeScalars.first else { return false }
        let value = scalar.value
        
        // CJK Unified Ideographs ranges
        return (0x4E00...0x9FFF).contains(value) ||  // CJK Unified Ideographs
               (0x3400...0x4DBF).contains(value) ||  // CJK Extension A
               (0x20000...0x2A6DF).contains(value) || // CJK Extension B
               (0x2A700...0x2B73F).contains(value) || // CJK Extension C
               (0x2B740...0x2B81F).contains(value) || // CJK Extension D
               (0x2B820...0x2CEAF).contains(value) || // CJK Extension E
               (0x3000...0x303F).contains(value) ||  // CJK Symbols and Punctuation
               (0xFF00...0xFFEF).contains(value)     // Halfwidth and Fullwidth Forms
    }
    
    // MARK: - Extract Text Range
    static func extractRange(from text: String, start: Int, length: Int) -> String {
        let startIndex = text.index(text.startIndex, offsetBy: start, limitedBy: text.endIndex) ?? text.startIndex
        let endIndex = text.index(startIndex, offsetBy: length, limitedBy: text.endIndex) ?? text.endIndex
        
        return String(text[startIndex..<endIndex])
    }
}

// MARK: - Models
struct ParsedText {
    let originalText: String
    let normalizedText: String
    let paragraphs: [Paragraph]
    let characterCount: Int
    let wordCount: Int
}

struct Paragraph: Identifiable {
    let id: UUID
    let text: String
    let startPosition: Int
    let endPosition: Int
}

