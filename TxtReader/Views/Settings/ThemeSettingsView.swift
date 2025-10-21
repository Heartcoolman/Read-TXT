import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: ReaderSettings
    @ObservedObject var viewModel: ReaderViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("字体") {
                    Picker("字体", selection: $settings.fontName) {
                        ForEach(SettingsViewModel(settings: settings).availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("字号: \(Int(settings.fontSize))")
                        Slider(value: $settings.fontSize, in: 12...36, step: 1)
                    }
                }
                
                Section("间距") {
                    VStack(alignment: .leading) {
                        Text("行距: \(Int(settings.lineSpacing))")
                        Slider(value: $settings.lineSpacing, in: 0...20, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("段落间距: \(Int(settings.paragraphSpacing))")
                        Slider(value: $settings.paragraphSpacing, in: 0...30, step: 1)
                    }
                }
                
                Section("页边距") {
                    VStack(alignment: .leading) {
                        Text("水平边距: \(Int(settings.horizontalPadding))")
                        Slider(value: $settings.horizontalPadding, in: 20...80, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("垂直边距: \(Int(settings.verticalPadding))")
                        Slider(value: $settings.verticalPadding, in: 20...80, step: 1)
                    }
                }
                
                Section("主题") {
                    Picker("主题", selection: $settings.theme) {
                        ForEach(SettingsViewModel(settings: settings).themes, id: \.0) { theme in
                            Text(theme.1).tag(theme.0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("阅读模式") {
                    Picker("模式", selection: $settings.readingMode) {
                        ForEach(SettingsViewModel(settings: settings).readingModes, id: \.0) { mode in
                            Text(mode.1).tag(mode.0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: settings.readingMode) { _, newValue in
                        Task {
                            if newValue == "paged" {
                                await viewModel.paginateText(settings: settings)
                            }
                        }
                    }
                }
                
                Section {
                    Button("重新分页") {
                        Task {
                            await viewModel.paginateText(settings: settings)
                        }
                    }
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

