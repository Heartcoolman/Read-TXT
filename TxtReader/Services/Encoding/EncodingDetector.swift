import Foundation

class EncodingDetector {
    
    // MARK: - Supported Encodings
    static let supportedEncodings: [(String.Encoding, String)] = [
        (.utf8, "UTF-8"),
        (.utf16, "UTF-16"),
        (.utf16BigEndian, "UTF-16 BE"),
        (.utf16LittleEndian, "UTF-16 LE"),
        (.utf32, "UTF-32"),
        (.utf32BigEndian, "UTF-32 BE"),
        (.utf32LittleEndian, "UTF-32 LE"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))), "GB18030"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))), "Big5"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.shiftJIS.rawValue))), "Shift-JIS"),
        (.isoLatin1, "ISO-8859-1"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsLatin1)), "Windows-1252"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.KOI8_R.rawValue))), "KOI8-R"),
        (String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))), "EUC-KR"),
    ]
    
    // MARK: - Auto Detect Encoding
    static func detectEncoding(data: Data, fileName: String? = nil) -> DetectionResult {
        // Step 1: Check BOM (Byte Order Mark)
        if let bomResult = checkBOM(data: data) {
            return bomResult
        }
        
        // Step 2: Try UTF-8 (most common)
        if let _ = String(data: data, encoding: .utf8) {
            let confidence = calculateUTF8Confidence(data: data)
            if confidence > 0.8 {
                return DetectionResult(encoding: .utf8, encodingName: "UTF-8", confidence: confidence)
            }
        }
        
        // Step 3: Statistical analysis for Chinese encodings
        let chineseResult = detectChineseEncoding(data: data)
        if chineseResult.confidence > 0.6 {
            return chineseResult
        }
        
        // Step 4: Try other encodings
        for (encoding, name) in supportedEncodings {
            if let _ = String(data: data, encoding: encoding) {
                let confidence = calculateEncodingConfidence(data: data, encoding: encoding)
                if confidence > 0.7 {
                    return DetectionResult(encoding: encoding, encodingName: name, confidence: confidence)
                }
            }
        }
        
        // Fallback to UTF-8
        return DetectionResult(encoding: .utf8, encodingName: "UTF-8", confidence: 0.5)
    }
    
    // MARK: - BOM Detection
    private static func checkBOM(data: Data) -> DetectionResult? {
        guard data.count >= 2 else { return nil }
        
        let bytes = [UInt8](data.prefix(4))
        
        // UTF-8 BOM: EF BB BF
        if bytes.count >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF {
            return DetectionResult(encoding: .utf8, encodingName: "UTF-8 (BOM)", confidence: 1.0, hasBOM: true)
        }
        
        // UTF-16 LE BOM: FF FE
        if bytes[0] == 0xFF && bytes[1] == 0xFE {
            if bytes.count >= 4 && bytes[2] == 0x00 && bytes[3] == 0x00 {
                // UTF-32 LE
                return DetectionResult(encoding: .utf32LittleEndian, encodingName: "UTF-32 LE (BOM)", confidence: 1.0, hasBOM: true)
            }
            return DetectionResult(encoding: .utf16LittleEndian, encodingName: "UTF-16 LE (BOM)", confidence: 1.0, hasBOM: true)
        }
        
        // UTF-16 BE BOM: FE FF
        if bytes[0] == 0xFE && bytes[1] == 0xFF {
            return DetectionResult(encoding: .utf16BigEndian, encodingName: "UTF-16 BE (BOM)", confidence: 1.0, hasBOM: true)
        }
        
        // UTF-32 BE BOM: 00 00 FE FF
        if bytes.count >= 4 && bytes[0] == 0x00 && bytes[1] == 0x00 && bytes[2] == 0xFE && bytes[3] == 0xFF {
            return DetectionResult(encoding: .utf32BigEndian, encodingName: "UTF-32 BE (BOM)", confidence: 1.0, hasBOM: true)
        }
        
        return nil
    }
    
    // MARK: - UTF-8 Confidence
    private static func calculateUTF8Confidence(data: Data) -> Double {
        let sampleSize = min(data.count, 10000)
        let sampleData = data.prefix(sampleSize)
        
        var validSequences = 0
        var totalSequences = 0
        var i = 0
        
        while i < sampleData.count {
            let byte = sampleData[i]
            
            if byte <= 0x7F {
                // ASCII
                validSequences += 1
                i += 1
            } else if byte >= 0xC0 && byte <= 0xDF {
                // 2-byte sequence
                if i + 1 < sampleData.count && (sampleData[i + 1] & 0xC0) == 0x80 {
                    validSequences += 1
                    i += 2
                } else {
                    totalSequences += 1
                    i += 1
                }
            } else if byte >= 0xE0 && byte <= 0xEF {
                // 3-byte sequence (most Chinese characters)
                if i + 2 < sampleData.count &&
                   (sampleData[i + 1] & 0xC0) == 0x80 &&
                   (sampleData[i + 2] & 0xC0) == 0x80 {
                    validSequences += 1
                    i += 3
                } else {
                    totalSequences += 1
                    i += 1
                }
            } else if byte >= 0xF0 && byte <= 0xF7 {
                // 4-byte sequence
                if i + 3 < sampleData.count &&
                   (sampleData[i + 1] & 0xC0) == 0x80 &&
                   (sampleData[i + 2] & 0xC0) == 0x80 &&
                   (sampleData[i + 3] & 0xC0) == 0x80 {
                    validSequences += 1
                    i += 4
                } else {
                    totalSequences += 1
                    i += 1
                }
            } else {
                totalSequences += 1
                i += 1
            }
            
            totalSequences += 1
        }
        
        return totalSequences > 0 ? Double(validSequences) / Double(totalSequences) : 0
    }
    
    // MARK: - Chinese Encoding Detection
    private static func detectChineseEncoding(data: Data) -> DetectionResult {
        let sampleSize = min(data.count, 10000)
        let sampleData = data.prefix(sampleSize)
        
        var gbkScore = 0.0
        var big5Score = 0.0
        
        var i = 0
        while i < sampleData.count - 1 {
            let byte1 = sampleData[i]
            let byte2 = sampleData[i + 1]
            
            // GBK/GB18030: First byte 0x81-0xFE, second byte 0x40-0xFE
            if (0x81...0xFE).contains(byte1) && 
               ((0x40...0x7E).contains(byte2) || (0x80...0xFE).contains(byte2)) {
                gbkScore += 1.0
            }
            
            // Big5: First byte 0x81-0xFE, second byte 0x40-0x7E or 0x80-0xFE
            if (0xA1...0xF9).contains(byte1) && 
               ((0x40...0x7E).contains(byte2) || (0xA1...0xFE).contains(byte2)) {
                big5Score += 1.0
            }
            
            i += 1
        }
        
        let totalBytes = Double(sampleData.count / 2)
        gbkScore = totalBytes > 0 ? gbkScore / totalBytes : 0
        big5Score = totalBytes > 0 ? big5Score / totalBytes : 0
        
        if gbkScore > big5Score && gbkScore > 0.3 {
            let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
            return DetectionResult(encoding: encoding, encodingName: "GB18030", confidence: min(gbkScore, 0.95))
        } else if big5Score > 0.3 {
            let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue)))
            return DetectionResult(encoding: encoding, encodingName: "Big5", confidence: min(big5Score, 0.95))
        }
        
        return DetectionResult(encoding: .utf8, encodingName: "UTF-8", confidence: 0)
    }
    
    // MARK: - General Encoding Confidence
    private static func calculateEncodingConfidence(data: Data, encoding: String.Encoding) -> Double {
        guard let string = String(data: data, encoding: encoding) else {
            return 0
        }
        
        // Check for replacement characters
        let replacementCount = string.filter { $0 == "\u{FFFD}" }.count
        let confidence = 1.0 - (Double(replacementCount) / Double(max(string.count, 1)))
        
        return confidence
    }
    
    // MARK: - Preview Text
    static func previewText(data: Data, encoding: String.Encoding, lines: Int = 5) -> String {
        guard let text = String(data: data, encoding: encoding) else {
            return "无法使用此编码解析文本"
        }
        
        let previewLines = text.components(separatedBy: .newlines).prefix(lines)
        return previewLines.joined(separator: "\n")
    }
}

// MARK: - Detection Result
struct DetectionResult {
    let encoding: String.Encoding
    let encodingName: String
    let confidence: Double
    let hasBOM: Bool
    
    init(encoding: String.Encoding, encodingName: String, confidence: Double, hasBOM: Bool = false) {
        self.encoding = encoding
        self.encodingName = encodingName
        self.confidence = confidence
        self.hasBOM = hasBOM
    }
}

