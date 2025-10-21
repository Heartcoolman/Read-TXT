import SwiftUI

struct KeyboardShortcuts {
    // Navigation
    static let nextPage = KeyEquivalent(" ")
    static let previousPage = KeyEquivalent(" ") // With Shift modifier
    static let firstPage = KeyEquivalent("h") // Home
    static let lastPage = KeyEquivalent("e") // End
    
    // Features
    static let search = KeyEquivalent("f")
    static let tableOfContents = KeyEquivalent("t")
    static let bookmarks = KeyEquivalent("b")
    static let settings = KeyEquivalent(",")
    
    // Reading
    static let toggleMenu = KeyEquivalent("m")
    static let addBookmark = KeyEquivalent("d")
    static let toggleSpeech = KeyEquivalent("s")
    
    // Close
    static let closeReader = KeyEquivalent("w")
}

extension View {
    func readerKeyboardShortcuts(
        viewModel: ReaderViewModel,
        showingMenu: Binding<Bool>,
        showingTableOfContents: Binding<Bool>,
        showingSearch: Binding<Bool>,
        showingBookmarks: Binding<Bool>,
        showingSettings: Binding<Bool>,
        dismiss: DismissAction
    ) -> some View {
        self
            .background(
                Group {
                    // Navigation
                    Button("") { viewModel.nextPage() }
                        .keyboardShortcut(KeyboardShortcuts.nextPage, modifiers: [])
                        .hidden()
                    
                    Button("") { viewModel.previousPage() }
                        .keyboardShortcut(KeyboardShortcuts.previousPage, modifiers: .shift)
                        .hidden()
                    
                    Button("") { viewModel.previousPage() }
                        .keyboardShortcut(.upArrow, modifiers: [])
                        .hidden()
                    
                    Button("") { viewModel.nextPage() }
                        .keyboardShortcut(.downArrow, modifiers: [])
                        .hidden()
                    
                    Button("") { viewModel.previousPage() }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        .hidden()
                    
                    Button("") { viewModel.nextPage() }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        .hidden()
                    
                    // Features
                    Button("") { showingSearch.wrappedValue = true }
                        .keyboardShortcut(KeyboardShortcuts.search, modifiers: .command)
                        .hidden()
                    
                    Button("") { showingTableOfContents.wrappedValue = true }
                        .keyboardShortcut(KeyboardShortcuts.tableOfContents, modifiers: .command)
                        .hidden()
                    
                    Button("") { showingBookmarks.wrappedValue = true }
                        .keyboardShortcut(KeyboardShortcuts.bookmarks, modifiers: .command)
                        .hidden()
                    
                    Button("") { showingSettings.wrappedValue = true }
                        .keyboardShortcut(KeyboardShortcuts.settings, modifiers: .command)
                        .hidden()
                    
                    // Reading
                    Button("") { showingMenu.wrappedValue.toggle() }
                        .keyboardShortcut(KeyboardShortcuts.toggleMenu, modifiers: .command)
                        .hidden()
                    
                    Button("") { viewModel.addBookmark() }
                        .keyboardShortcut(KeyboardShortcuts.addBookmark, modifiers: .command)
                        .hidden()
                    
                    Button("") { viewModel.toggleSpeech() }
                        .keyboardShortcut(KeyboardShortcuts.toggleSpeech, modifiers: [.command, .shift])
                        .hidden()
                    
                    // Close
                    Button("") { dismiss() }
                        .keyboardShortcut(KeyboardShortcuts.closeReader, modifiers: .command)
                        .hidden()
                }
            )
    }
}
