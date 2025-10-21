import Foundation

class WebDAVClient {
    private let session: URLSession
    private var account: WebDAVAccount
    private var password: String
    
    init(account: WebDAVAccount, password: String) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        self.account = account
        self.password = password
    }
    
    // MARK: - List Directory
    func listDirectory(path: String) async throws -> [WebDAVItem] {
        guard let url = buildURL(path: path) else {
            throw WebDAVError.parseError("无效的服务器地址")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        // Add authentication
        addAuthentication(to: &request)
        
        // PROPFIND XML body
        let propfindXML = """
        <?xml version="1.0" encoding="utf-8"?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:displayname/>
                <D:getcontentlength/>
                <D:getcontenttype/>
                <D:getlastmodified/>
                <D:resourcetype/>
            </D:prop>
        </D:propfind>
        """
        request.httpBody = propfindXML.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WebDAVError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try parseMultistatusResponse(data: data, basePath: path)
    }
    
    // MARK: - Download File
    func downloadFile(path: String, progressHandler: ((Double) -> Void)? = nil) async throws -> Data {
        guard let url = buildURL(path: path) else {
            throw WebDAVError.parseError("无效的文件路径")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthentication(to: &request)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WebDAVError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    // MARK: - Stream Download (for large files)
    func streamDownload(path: String, chunkSize: Int = 1024 * 100) async throws -> AsyncThrowingStream<Data, Error> {
        guard let url = buildURL(path: path) else {
            throw WebDAVError.parseError("无效的文件路径")
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    self.addAuthentication(to: &request)
                    
                    let (asyncBytes, response) = try await self.session.bytes(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        throw WebDAVError.httpError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
                    }
                    
                    var buffer = Data()
                    for try await byte in asyncBytes {
                        buffer.append(byte)
                        if buffer.count >= chunkSize {
                            continuation.yield(buffer)
                            buffer = Data()
                        }
                    }
                    
                    if !buffer.isEmpty {
                        continuation.yield(buffer)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func buildURL(path: String) -> URL? {
        var urlString = account.serverURL
        
        // Ensure server URL has scheme
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        if path.hasPrefix("/") {
            urlString += String(path.dropFirst())
        } else {
            urlString += path
        }
        
        return URL(string: urlString)
    }
    
    private func addAuthentication(to request: inout URLRequest) {
        let credentials = "\(account.username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
    }
    
    private func parseMultistatusResponse(data: Data, basePath: String) throws -> [WebDAVItem] {
        let parser = WebDAVXMLParser()
        return try parser.parse(data: data, basePath: basePath)
    }
}

// MARK: - WebDAV Models
struct WebDAVItem: Identifiable {
    let id: UUID
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64?
    let contentType: String?
    let lastModified: Date?
    
    init(name: String, path: String, isDirectory: Bool, size: Int64? = nil, contentType: String? = nil, lastModified: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.size = size
        self.contentType = contentType
        self.lastModified = lastModified
    }
}

enum WebDAVError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case parseError(String)
    case authenticationFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "无效的服务器响应"
        case .httpError(let code):
            return "HTTP 错误: \(code)"
        case .parseError(let message):
            return "解析错误: \(message)"
        case .authenticationFailed:
            return "认证失败"
        }
    }
}

// MARK: - XML Parser
class WebDAVXMLParser: NSObject, XMLParserDelegate {
    private var items: [WebDAVItem] = []
    private var currentItem: [String: String] = [:]
    private var currentElement: String = ""
    private var currentValue: String = ""
    private var basePath: String = ""
    
    func parse(data: Data, basePath: String) throws -> [WebDAVItem] {
        self.basePath = basePath
        items = []
        currentItem = [:]
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        guard parser.parse() else {
            throw WebDAVError.parseError("XML 解析失败")
        }
        
        return items
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentValue = ""
        
        if elementName == "D:response" || elementName == "response" {
            currentItem = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "D:href", "href":
            currentItem["href"] = currentValue
        case "D:displayname", "displayname":
            currentItem["displayname"] = currentValue
        case "D:getcontentlength", "getcontentlength":
            currentItem["size"] = currentValue
        case "D:getcontenttype", "getcontenttype":
            currentItem["contentType"] = currentValue
        case "D:resourcetype", "resourcetype":
            if currentValue.contains("collection") || currentItem["isCollection"] == "true" {
                currentItem["isCollection"] = "true"
            }
        case "D:collection", "collection":
            currentItem["isCollection"] = "true"
        case "D:response", "response":
            if let item = createWebDAVItem(from: currentItem) {
                items.append(item)
            }
        default:
            break
        }
    }
    
    private func createWebDAVItem(from dict: [String: String]) -> WebDAVItem? {
        guard let href = dict["href"] else { return nil }
        
        // Decode URL path
        let decodedPath = href.removingPercentEncoding ?? href
        let name = (decodedPath as NSString).lastPathComponent
        
        // Skip parent directory
        if decodedPath == basePath || decodedPath == basePath + "/" {
            return nil
        }
        
        let isDirectory = dict["isCollection"] == "true"
        let size = dict["size"].flatMap { Int64($0) }
        let contentType = dict["contentType"]
        
        return WebDAVItem(
            name: name,
            path: decodedPath,
            isDirectory: isDirectory,
            size: size,
            contentType: contentType,
            lastModified: nil
        )
    }
}

