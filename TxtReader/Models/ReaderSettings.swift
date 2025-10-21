import SwiftUI

class ReaderSettings: ObservableObject {
    @AppStorage("fontSize") var fontSize: Double = 18.0
    @AppStorage("lineSpacing") var lineSpacing: Double = 8.0
    @AppStorage("paragraphSpacing") var paragraphSpacing: Double = 12.0
    @AppStorage("horizontalPadding") var horizontalPadding: Double = 40.0
    @AppStorage("verticalPadding") var verticalPadding: Double = 40.0
    @AppStorage("fontName") var fontName: String = "System"
    @AppStorage("theme") var theme: String = "auto"
    @AppStorage("readingMode") var readingMode: String = "paged" // paged or scroll
    @AppStorage("brightness") var brightness: Double = -1.0 // -1 means use system
    
    var currentTheme: ReaderTheme {
        switch theme {
        case "light":
            return .light
        case "dark":
            return .dark
        case "sepia":
            return .sepia
        default:
            return .auto
        }
    }
}

enum ReaderTheme {
    case auto
    case light
    case dark
    case sepia
    
    var backgroundColor: Color {
        switch self {
        case .auto:
            return Color(uiColor: .systemBackground)
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case .sepia:
            return Color(red: 0.98, green: 0.96, blue: 0.90)
        }
    }
    
    var textColor: Color {
        switch self {
        case .auto:
            return Color(uiColor: .label)
        case .light:
            return Color.black
        case .dark:
            return Color.white
        case .sepia:
            return Color(red: 0.2, green: 0.2, blue: 0.15)
        }
    }
}

