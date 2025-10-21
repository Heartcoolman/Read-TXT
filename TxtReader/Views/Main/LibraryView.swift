import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.lastReadDate, order: .reverse) private var books: [Book]
    @State private var selectedBook: Book?
    @State private var showingReader = false
    @StateObject private var settings = ReaderSettings()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedBook) {
                ForEach(books) { book in
                    BookRow(book: book)
                        .tag(book)
                        .onTapGesture {
                            selectedBook = book
                            showingReader = true
                        }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationTitle("我的书库")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            if let book = selectedBook {
                BookDetailView(book: book, settings: settings)
            } else {
                Text("选择一本书开始阅读")
                    .foregroundColor(.secondary)
            }
        }
        .fullScreenCover(isPresented: $showingReader) {
            if let book = selectedBook {
                ReaderView(book: book, settings: settings)
            }
        }
    }
    
    private func deleteBooks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(books[index])
        }
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.title)
                .font(.headline)
            
            if let author = book.author {
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(formatFileSize(book.fileSize))", systemImage: "doc.text")
                Spacer()
                if let progress = book.progress {
                    Text("\(Int(progress.percentage * 100))%")
                        .foregroundColor(.blue)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct BookDetailView: View {
    let book: Book
    let settings: ReaderSettings
    @State private var showingReader = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(book.title)
                .font(.title)
                .fontWeight(.bold)
            
            if let author = book.author {
                Text(author)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "文件大小", value: formatFileSize(book.fileSize))
                InfoRow(label: "编码", value: book.encoding)
                InfoRow(label: "来源", value: book.source == .webdav ? "WebDAV" : "本地")
                
                if let progress = book.progress {
                    InfoRow(label: "阅读进度", value: "\(Int(progress.percentage * 100))%")
                    InfoRow(label: "上次阅读", value: formatDate(progress.lastReadDate))
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            
            Button(action: {
                showingReader = true
            }) {
                Label("开始阅读", systemImage: "book.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showingReader) {
            ReaderView(book: book, settings: settings)
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Book.self, ReadingProgress.self, Bookmark.self])
}

