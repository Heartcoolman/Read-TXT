import SwiftUI
import SwiftData

struct WebDAVBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = WebDAVViewModel()
    @State private var showingAddAccount = false
    @State private var selectedBook: Book?
    @State private var showingReader = false
    @StateObject private var settings = ReaderSettings()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.selectedAccount == nil {
                    accountSelectionView
                } else {
                    fileBrowserView
                }
            }
            .navigationTitle(viewModel.selectedAccount?.name ?? "WebDAV")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.selectedAccount != nil {
                        Button("返回") {
                            viewModel.selectedAccount = nil
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAccount = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddWebDAVAccountView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showingReader) {
                if let book = selectedBook {
                    ReaderView(book: book, settings: settings)
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }
    
    private var accountSelectionView: some View {
        List {
            ForEach(viewModel.accounts) { account in
                Button(action: {
                    Task {
                        await viewModel.connect(to: account)
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.name)
                            .font(.headline)
                        Text(account.serverURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    try? viewModel.deleteAccount(viewModel.accounts[index])
                }
            }
            
            if viewModel.accounts.isEmpty {
                Text("点击右上角 + 添加 WebDAV 账户")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    private var fileBrowserView: some View {
        List {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(viewModel.items) { item in
                    WebDAVItemRow(item: item) {
                        handleItemTap(item)
                    }
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    private func handleItemTap(_ item: WebDAVItem) {
        if item.isDirectory {
            Task {
                await viewModel.loadDirectory(path: item.path)
            }
        } else if item.name.hasSuffix(".txt") {
            Task {
                if let book = await viewModel.downloadAndOpen(item: item) {
                    selectedBook = book
                    showingReader = true
                }
            }
        }
    }
}

struct WebDAVItemRow: View {
    let item: WebDAVItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: item.isDirectory ? "folder.fill" : "doc.text.fill")
                    .foregroundColor(item.isDirectory ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                    
                    if let size = item.size {
                        Text(formatFileSize(size))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if !item.isDirectory {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct AddWebDAVAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WebDAVViewModel
    
    @State private var name = ""
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("账户信息") {
                    TextField("名称", text: $name)
                    TextField("服务器地址", text: $serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("用户名", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("密码", text: $password)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("添加 WebDAV 账户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty || serverURL.isEmpty || username.isEmpty || password.isEmpty || isLoading)
                }
            }
        }
    }
    
    private func saveAccount() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await viewModel.addAccount(
                    name: name,
                    serverURL: serverURL,
                    username: username,
                    password: password
                )
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    WebDAVBrowserView()
        .modelContainer(for: [Book.self, WebDAVAccount.self])
}

