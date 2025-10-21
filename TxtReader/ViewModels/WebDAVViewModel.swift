import Foundation
import SwiftUI
import SwiftData

@MainActor
class WebDAVViewModel: ObservableObject {
    @Published var accounts: [WebDAVAccount] = []
    @Published var currentPath: String = "/"
    @Published var items: [WebDAVItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedAccount: WebDAVAccount?
    
    private var webdavClient: WebDAVClient?
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadAccounts()
    }
    
    // MARK: - Load Accounts
    func loadAccounts() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<WebDAVAccount>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            accounts = try context.fetch(descriptor)
        } catch {
            errorMessage = "加载账户失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Connect to Account
    func connect(to account: WebDAVAccount) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get password from keychain
            let password = try WebDAVCredentialManager.shared.getPassword(accountID: account.id)
            
            // Create WebDAV client
            webdavClient = WebDAVClient(account: account, password: password)
            
            // Test connection by loading root directory
            selectedAccount = account
            await loadDirectory(path: "/")
            
            // If we get here without error, connection is successful
            if errorMessage != nil {
                // loadDirectory failed, clear selection
                webdavClient = nil
                selectedAccount = nil
            }
        } catch let keychainError as KeychainError {
            errorMessage = "读取密码失败: \(keychainError.localizedDescription)"
            webdavClient = nil
            selectedAccount = nil
            isLoading = false
            return
        } catch {
            errorMessage = "连接失败: \(error.localizedDescription)"
            webdavClient = nil
            selectedAccount = nil
            isLoading = false
            return
        }
        
        isLoading = false
    }
    
    // MARK: - Load Directory
    func loadDirectory(path: String) async {
        guard let client = webdavClient else {
            errorMessage = "WebDAV 客户端未初始化"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await client.listDirectory(path: path)
            currentPath = path
            errorMessage = nil // 明确清除错误
        } catch let webdavError as WebDAVError {
            // 提供更友好的错误消息
            switch webdavError {
            case .authenticationFailed:
                errorMessage = "认证失败，请检查用户名和密码"
            case .httpError(let code):
                errorMessage = "HTTP 错误 \(code): \(httpErrorDescription(code))"
            case .invalidResponse:
                errorMessage = "服务器响应无效"
            case .parseError(let msg):
                errorMessage = "解析错误: \(msg)"
            }
            items = []
        } catch {
            // 网络错误或其他错误
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                errorMessage = "网络错误: \(networkErrorDescription(nsError.code))"
            } else {
                errorMessage = "加载目录失败: \(error.localizedDescription)"
            }
            items = []
        }
        
        isLoading = false
    }
    
    // MARK: - Error Descriptions
    private func httpErrorDescription(_ code: Int) -> String {
        switch code {
        case 401: return "需要认证"
        case 403: return "无权访问"
        case 404: return "路径不存在"
        case 500: return "服务器内部错误"
        case 503: return "服务不可用"
        default: return "未知错误"
        }
    }
    
    private func networkErrorDescription(_ code: Int) -> String {
        switch code {
        case NSURLErrorNotConnectedToInternet: return "无网络连接"
        case NSURLErrorTimedOut: return "连接超时"
        case NSURLErrorCannotFindHost: return "找不到服务器"
        case NSURLErrorCannotConnectToHost: return "无法连接到服务器，请检查地址"
        case NSURLErrorNetworkConnectionLost: return "网络连接中断"
        case NSURLErrorDNSLookupFailed: return "DNS 查询失败"
        case NSURLErrorBadURL: return "服务器地址格式错误"
        case NSURLErrorSecureConnectionFailed: return "安全连接失败，请检查 HTTPS 配置"
        default: return "网络错误 (\(code))"
        }
    }
    
    // MARK: - Download and Open File
    func downloadAndOpen(item: WebDAVItem) async -> Book? {
        guard let client = webdavClient,
              let account = selectedAccount,
              let context = modelContext else { return nil }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Download file
            let data = try await client.downloadFile(path: item.path)
            
            // Detect encoding
            let detection = EncodingDetector.detectEncoding(data: data, fileName: item.name)
            
            // Decode text
            let text = try TextDecoder.decode(data: data, encoding: detection.encoding)
            
            // Save to local temp file
            let tempPath = saveToTemp(data: data, fileName: item.name)
            
            // Create book record
            let book = Book(
                title: item.name,
                filePath: tempPath,
                fileSize: item.size ?? Int64(data.count),
                encoding: detection.encodingName,
                source: .webdav,
                webdavURL: item.path,
                webdavAccountID: account.id,
                totalCharacters: text.count
            )
            
            context.insert(book)
            try context.save()
            
            isLoading = false
            return book
        } catch {
            errorMessage = "下载失败: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Save to Temp
    private func saveToTemp(data: Data, fileName: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
        return fileURL.path
    }
    
    // MARK: - Add Account
    func addAccount(name: String, serverURL: String, username: String, password: String) async throws {
        guard let context = modelContext else { return }
        
        let account = WebDAVAccount(name: name, serverURL: serverURL, username: username)
        
        try await DataManager.shared.saveWebDAVAccount(account, password: password, to: context)
        
        loadAccounts()
    }
    
    // MARK: - Delete Account
    func deleteAccount(_ account: WebDAVAccount) throws {
        guard let context = modelContext else { return }
        
        try DataManager.shared.deleteWebDAVAccount(account, from: context)
        loadAccounts()
    }
}

