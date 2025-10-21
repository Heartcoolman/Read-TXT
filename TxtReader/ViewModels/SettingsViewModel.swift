import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: ReaderSettings
    
    init(settings: ReaderSettings) {
        self.settings = settings
    }
    
    // MARK: - Font Options
    let availableFonts = [
        "System",
        "Songti SC",
        "Heiti SC",
        "Kaiti SC",
        "PingFang SC",
        "Georgia",
        "Times New Roman",
        "Palatino"
    ]
    
    // MARK: - Theme Options
    let themes = [
        ("auto", "跟随系统"),
        ("light", "明亮"),
        ("dark", "暗黑"),
        ("sepia", "护眼")
    ]
    
    // MARK: - Reading Mode Options
    let readingModes = [
        ("paged", "分页模式"),
        ("scroll", "滚动模式")
    ]
}

