import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("书库", systemImage: "books.vertical")
                }
                .tag(0)
            
            WebDAVBrowserView()
                .tabItem {
                    Label("WebDAV", systemImage: "externaldrive.connected.to.line.below")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, ReadingProgress.self, Bookmark.self, WebDAVAccount.self])
}

