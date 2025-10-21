import UIKit
import CoreText

class PaginationEngine {
    
    // MARK: - Paginate Text
    static func paginate(
        text: String,
        pageSize: CGSize,
        font: UIFont,
        lineSpacing: CGFloat,
        paragraphSpacing: CGFloat
    ) -> [Page] {
        var pages: [Page] = []
        
        // 性能优化：限制最大分页数
        let maxPages = 1000
        
        // Create attributed string with formatting
        let attributedString = createAttributedString(
            text: text,
            font: font,
            lineSpacing: lineSpacing,
            paragraphSpacing: paragraphSpacing
        )
        
        // Create framesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        
        var currentPosition = 0
        let textLength = attributedString.length
        var pageNumber = 1
        
        // 预分配数组容量，减少重新分配
        pages.reserveCapacity(min(textLength / 1000, maxPages))
        
        while currentPosition < textLength && pages.count < maxPages {
            // Create path for the page
            let path = CGPath(rect: CGRect(origin: .zero, size: pageSize), transform: nil)
            
            // Get the range that fits in this page
            let range = CFRangeMake(currentPosition, 0)
            let frame = CTFramesetterCreateFrame(framesetter, range, path, nil)
            
            // Get visible range
            let visibleRange = CTFrameGetVisibleStringRange(frame)
            
            if visibleRange.length == 0 {
                break
            }
            
            // Extract text for this page
            let startIndex = attributedString.string.index(attributedString.string.startIndex, offsetBy: currentPosition)
            let endIndex = attributedString.string.index(startIndex, offsetBy: visibleRange.length)
            let pageText = String(attributedString.string[startIndex..<endIndex])
            
            // Create page
            pages.append(Page(
                id: UUID(),
                number: pageNumber,
                text: pageText,
                attributedText: attributedString.attributedSubstring(from: NSRange(location: currentPosition, length: visibleRange.length)),
                startPosition: currentPosition,
                endPosition: currentPosition + visibleRange.length
            ))
            
            currentPosition += visibleRange.length
            pageNumber += 1
        }
        
        return pages
    }
    
    // MARK: - Create Attributed String
    private static func createAttributedString(
        text: String,
        font: UIFont,
        lineSpacing: CGFloat,
        paragraphSpacing: CGFloat
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    // MARK: - Find Page at Position
    static func findPageIndex(at position: Int, in pages: [Page]) -> Int {
        for (index, page) in pages.enumerated() {
            if position >= page.startPosition && position < page.endPosition {
                return index
            }
        }
        return 0
    }
    
    // MARK: - Calculate Reading Time
    static func estimateReadingTime(characterCount: Int, readingSpeed: Int = 500) -> TimeInterval {
        // Default reading speed: 500 characters per minute
        let minutes = Double(characterCount) / Double(readingSpeed)
        return minutes * 60 // Convert to seconds
    }
}

// MARK: - Page Model
struct Page: Identifiable {
    let id: UUID
    let number: Int
    let text: String
    let attributedText: NSAttributedString
    let startPosition: Int
    let endPosition: Int
}

