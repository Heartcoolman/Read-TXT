import Foundation

class StreamReader {
    private var fileHandle: FileHandle?
    private var encoding: String.Encoding
    private let chunkSize: Int
    
    init(path: String, encoding: String.Encoding = .utf8, chunkSize: Int = 1024 * 100) {
        self.encoding = encoding
        self.chunkSize = chunkSize
        
        if let handle = FileHandle(forReadingAtPath: path) {
            self.fileHandle = handle
        }
    }
    
    deinit {
        try? fileHandle?.close()
    }
    
    // MARK: - Read Chunk
    func readChunk() -> String? {
        guard let handle = fileHandle else { return nil }
        
        let data = handle.readData(ofLength: chunkSize)
        if data.isEmpty {
            return nil
        }
        
        return String(data: data, encoding: encoding)
    }
    
    // MARK: - Read All
    func readAll() -> String? {
        guard let handle = fileHandle else { return nil }
        
        let data = handle.readDataToEndOfFile()
        return String(data: data, encoding: encoding)
    }
    
    // MARK: - Seek to Position
    func seek(to position: UInt64) {
        try? fileHandle?.seek(toOffset: position)
    }
    
    // MARK: - Async Stream Reading
    func stream() -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                while let chunk = self.readChunk() {
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
        }
    }
    
    // MARK: - Read First N Bytes (for encoding detection)
    static func readFirst(path: String, bytes: Int = 10000) -> Data? {
        guard let handle = FileHandle(forReadingAtPath: path) else { return nil }
        defer { try? handle.close() }
        
        return handle.readData(ofLength: bytes)
    }
}

