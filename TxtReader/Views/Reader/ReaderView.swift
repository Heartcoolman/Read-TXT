import SwiftUI
import SwiftData

struct ReaderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    
    @State private var showingMenu = false
    @State private var showingTableOfContents = false
    @State private var showingSearch = false
    @State private var showingBookmarks = false
    @State private var showingSettings = false
    
    init(book: Book, settings: ReaderSettings) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book))
        self.settings = settings
    }
    
    var body: some View {
        ZStack {
            // Background
            settings.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else {
                    if settings.readingMode == "paged" {
                        PagedReaderView(
                            viewModel: viewModel,
                            settings: settings,
                            showingMenu: $showingMenu
                        )
                    } else {
                        ScrollReaderView(
                            viewModel: viewModel,
                            settings: settings,
                            showingMenu: $showingMenu
                        )
                    }
                }
            }
            
            // Top Menu Bar
            if showingMenu {
                VStack {
                    topMenuBar
                    Spacer()
                    bottomMenuBar
                }
                .transition(.move(edge: .top))
            }
        }
        .statusBar(hidden: !showingMenu)
        .readerKeyboardShortcuts(
            viewModel: viewModel,
            showingMenu: $showingMenu,
            showingTableOfContents: $showingTableOfContents,
            showingSearch: $showingSearch,
            showingBookmarks: $showingBookmarks,
            showingSettings: $showingSettings,
            dismiss: dismiss
        )
        .onAppear {
            viewModel.setModelContext(modelContext)
            Task {
                await viewModel.loadBook(settings: settings)
            }
        }
        .onDisappear {
            viewModel.updateProgress()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("阅读器")
        .announceForAccessibility("已打开 \(viewModel.book.title)")
        .sheet(isPresented: $showingTableOfContents) {
            TableOfContentsView(viewModel: viewModel, settings: settings)
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(viewModel: viewModel, settings: settings)
        }
        .sheet(isPresented: $showingBookmarks) {
            BookmarkListView(viewModel: viewModel, settings: settings)
        }
        .sheet(isPresented: $showingSettings) {
            ThemeSettingsView(settings: settings, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEncodingPicker) {
            EncodingPickerView(viewModel: viewModel)
        }
    }
    
    private var topMenuBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(settings.currentTheme.textColor)
                    .padding()
            }
            
            Text(viewModel.book.title)
                .font(.headline)
                .foregroundColor(settings.currentTheme.textColor)
                .lineLimit(1)
            
            Spacer()
            
            Menu {
                Button(action: { showingTableOfContents = true }) {
                    Label("目录", systemImage: "list.bullet")
                }
                
                Button(action: { showingSearch = true }) {
                    Label("搜索", systemImage: "magnifyingglass")
                }
                
                Button(action: { showingBookmarks = true }) {
                    Label("书签", systemImage: "bookmark")
                }
                
                Button(action: { viewModel.addBookmark() }) {
                    Label("添加书签", systemImage: "bookmark.fill")
                }
                
                Divider()
                
                Button(action: { viewModel.showEncodingPicker = true }) {
                    Label("更改编码", systemImage: "textformat")
                }
                
                Button(action: { viewModel.toggleSpeech() }) {
                    Label(viewModel.isSpeaking ? "停止朗读" : "开始朗读", 
                          systemImage: viewModel.isSpeaking ? "speaker.slash" : "speaker.wave.2")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(settings.currentTheme.textColor)
                    .padding()
            }
        }
        .background(settings.currentTheme.backgroundColor.opacity(0.95))
        .shadow(radius: 2)
    }
    
    private var bottomMenuBar: some View {
        VStack(spacing: 12) {
            // Progress bar
            if !viewModel.pages.isEmpty {
                VStack(spacing: 4) {
                    ProgressView(value: viewModel.readingProgress)
                        .tint(Color.blue)
                    
                    HStack {
                        Text("\(viewModel.currentPageIndex + 1) / \(viewModel.pages.count)")
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.readingProgress * 100))%")
                            .font(.caption)
                        
                        if viewModel.estimatedTimeRemaining > 0 {
                            Text("剩余 \(formatTime(viewModel.estimatedTimeRemaining))")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(settings.currentTheme.textColor.opacity(0.7))
                }
                .padding(.horizontal)
            }
            
            // Action buttons
            HStack(spacing: 40) {
                Button(action: { showingTableOfContents = true }) {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("目录")
                            .font(.caption)
                    }
                    .foregroundColor(settings.currentTheme.textColor)
                }
                
                Button(action: { showingSettings = true }) {
                    VStack {
                        Image(systemName: "textformat.size")
                        Text("设置")
                            .font(.caption)
                    }
                    .foregroundColor(settings.currentTheme.textColor)
                }
                
                Button(action: { viewModel.addBookmark() }) {
                    VStack {
                        Image(systemName: "bookmark")
                        Text("书签")
                            .font(.caption)
                    }
                    .foregroundColor(settings.currentTheme.textColor)
                }
                
                Button(action: { showingSearch = true }) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("搜索")
                            .font(.caption)
                    }
                    .foregroundColor(settings.currentTheme.textColor)
                }
            }
            .padding(.bottom)
        }
        .background(settings.currentTheme.backgroundColor.opacity(0.95))
        .shadow(radius: 2)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)分钟"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)小时\(mins)分钟"
        }
    }
}

