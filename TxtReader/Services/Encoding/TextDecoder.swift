import Foundation

class TextDecoder {
    
    // MARK: - Decode Text
    static func decode(data: Data, encoding: String.Encoding, removeBOM: Bool = true) throws -> String {
        var processedData = data
        
        // Remove BOM if needed
        if removeBOM {
            processedData = removeBOMIfPresent(data: data, encoding: encoding)
        }
        
        guard let text = String(data: processedData, encoding: encoding) else {
            throw DecoderError.decodingFailed(encoding: encoding)
        }
        
        // Normalize line endings
        return normalizeLineEndings(text)
    }
    
    // MARK: - Remove BOM
    private static func removeBOMIfPresent(data: Data, encoding: String.Encoding) -> Data {
        guard data.count >= 2 else { return data }
        
        let bytes = [UInt8](data.prefix(4))
        
        switch encoding {
        case .utf8:
            // UTF-8 BOM: EF BB BF
            if bytes.count >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF {
                return data.dropFirst(3)
            }
        case .utf16LittleEndian, .utf16:
            // UTF-16 LE BOM: FF FE
            if bytes[0] == 0xFF && bytes[1] == 0xFE {
                return data.dropFirst(2)
            }
        case .utf16BigEndian:
            // UTF-16 BE BOM: FE FF
            if bytes[0] == 0xFE && bytes[1] == 0xFF {
                return data.dropFirst(2)
            }
        case .utf32LittleEndian, .utf32:
            // UTF-32 LE BOM: FF FE 00 00
            if bytes.count >= 4 && bytes[0] == 0xFF && bytes[1] == 0xFE && bytes[2] == 0x00 && bytes[3] == 0x00 {
                return data.dropFirst(4)
            }
        case .utf32BigEndian:
            // UTF-32 BE BOM: 00 00 FE FF
            if bytes.count >= 4 && bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0xFE && bytes[3] == 0xFF {
                return data.dropFirst(4)
            }
        default:
            break
        }
        
        return data
    }
    
    // MARK: - Normalize Line Endings
    static func normalizeLineEndings(_ text: String) -> String {
        // Convert all line endings to \n
        return text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }
    
    // MARK: - Streaming Decode
    static func streamDecode(
        data: Data,
        encoding: String.Encoding,
        chunkSize: Int = 1024 * 50
    ) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                var remainingData = data
                var decodedText = ""
                
                while !remainingData.isEmpty {
                    let chunk = remainingData.prefix(chunkSize)
                    remainingData = remainingData.dropFirst(chunkSize)
                    
                    if let text = String(data: chunk, encoding: encoding) {
                        decodedText += text
                        
                        // Find complete lines
                        if let lastNewline = decodedText.lastIndex(of: "\n") {
                            let completeText = String(decodedText[..<lastNewline])
                            continuation.yield(normalizeLineEndings(completeText))
                            decodedText = String(decodedText[decodedText.index(after: lastNewline)...])
                        }
                    }
                }
                
                // Yield remaining text
                if !decodedText.isEmpty {
                    continuation.yield(normalizeLineEndings(decodedText))
                }
                
                continuation.finish()
            }
        }
    }
}

enum DecoderError: Error {
    case decodingFailed(encoding: String.Encoding)
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .decodingFailed(let encoding):
            return "无法使用编码 \(encoding.description) 解码文本"
        case .invalidData:
            return "无效的数据"
        }
    }
}

