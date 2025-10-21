import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = ReaderSettings()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("应用名称")
                        Spacer()
                        Text("TXT 阅读器")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("帮助") {
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("使用说明")
                    Text("反馈问题")
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
}

