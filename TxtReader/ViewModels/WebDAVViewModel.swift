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
            let password = try WebDAVCredentialManager.shared.getPassword(accountID: account.id)
            webdavClient = WebDAVClient(account: account, password: password)
            selectedAccount = account
            await loadDirectory(path: "/")
        } catch {
            errorMessage = "连接失败: \(error.localizedDescription)"
            // 重要：连接失败时清理状态
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
        } catch {
            errorMessage = "加载目录失败: \(error.localizedDescription)"
            items = [] // 清空列表避免显示旧数据
        }
        
        isLoading = false
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

