import SwiftUI
import SwiftData

struct BookmarkListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    
    @Query private var allBookmarks: [Bookmark]
    
    var bookmarks: [Bookmark] {
        allBookmarks.filter { $0.book?.id == viewModel.book.id }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if bookmarks.isEmpty {
                    Text("暂无书签")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(bookmarks) { bookmark in
                        Button(action: {
                            jumpToBookmark(bookmark)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                if let chapter = bookmark.chapterTitle {
                                    Text(chapter)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                Text(bookmark.excerpt)
                                    .font(.body)
                                    .lineLimit(2)
                                
                                if let note = bookmark.note {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .italic()
                                }
                                
                                HStack {
                                    Image(systemName: bookmark.type == .bookmark ? "bookmark.fill" : "highlighter")
                                        .foregroundColor(.gray)
                                    
                                    Text(formatDate(bookmark.createdDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteBookmarks)
                }
            }
            .navigationTitle("书签 (\(bookmarks.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func jumpToBookmark(_ bookmark: Bookmark) {
        if !viewModel.pages.isEmpty {
            let pageIndex = PaginationEngine.findPageIndex(at: bookmark.position, in: viewModel.pages)
            viewModel.goToPage(pageIndex)
        }
        dismiss()
    }
    
    private func deleteBookmarks(at offsets: IndexSet) {
        for index in offsets {
            let bookmark = bookmarks[index]
            DataManager.shared.deleteBookmark(bookmark, from: modelContext)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

