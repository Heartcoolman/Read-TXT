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
            // Navigation
            .keyboardShortcut(KeyboardShortcuts.nextPage, modifiers: []) {
                viewModel.nextPage()
            }
            .keyboardShortcut(KeyboardShortcuts.previousPage, modifiers: .shift) {
                viewModel.previousPage()
            }
            .keyboardShortcut(.upArrow, modifiers: []) {
                viewModel.previousPage()
            }
            .keyboardShortcut(.downArrow, modifiers: []) {
                viewModel.nextPage()
            }
            .keyboardShortcut(.leftArrow, modifiers: []) {
                viewModel.previousPage()
            }
            .keyboardShortcut(.rightArrow, modifiers: []) {
                viewModel.nextPage()
            }
            
            // Features
            .keyboardShortcut(KeyboardShortcuts.search, modifiers: .command) {
                showingSearch.wrappedValue = true
            }
            .keyboardShortcut(KeyboardShortcuts.tableOfContents, modifiers: .command) {
                showingTableOfContents.wrappedValue = true
            }
            .keyboardShortcut(KeyboardShortcuts.bookmarks, modifiers: .command) {
                showingBookmarks.wrappedValue = true
            }
            .keyboardShortcut(KeyboardShortcuts.settings, modifiers: .command) {
                showingSettings.wrappedValue = true
            }
            
            // Reading
            .keyboardShortcut(KeyboardShortcuts.toggleMenu, modifiers: .command) {
                showingMenu.wrappedValue.toggle()
            }
            .keyboardShortcut(KeyboardShortcuts.addBookmark, modifiers: .command) {
                viewModel.addBookmark()
            }
            .keyboardShortcut(KeyboardShortcuts.toggleSpeech, modifiers: [.command, .shift]) {
                viewModel.toggleSpeech()
            }
            
            // Close
            .keyboardShortcut(KeyboardShortcuts.closeReader, modifiers: .command) {
                dismiss()
            }
    }
}

