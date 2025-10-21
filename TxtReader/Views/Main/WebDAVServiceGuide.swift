import SwiftUI

struct WebDAVServiceGuide: View {
    @Environment(\.dismiss) private var dismiss
    
    let services = [
        ServiceConfig(
            name: "飞牛 fnOS",
            icon: "server.rack",
            serverFormat: "http://你的IP地址:5244/dav/",
            example: "http://192.168.1.100:5244/dav/",
            usernameHint: "飞牛用户名",
            passwordHint: "飞牛密码",
            notes: [
                "需要在飞牛系统中启用 WebDAV 服务",
                "使用局域网 IP 地址",
                "端口通常是 5244",
                "如使用 HTTPS 可能需要信任证书"
            ]
        ),
        ServiceConfig(
            name: "坚果云",
            icon: "cloud",
            serverFormat: "https://dav.jianguoyun.com/dav/",
            example: "https://dav.jianguoyun.com/dav/",
            usernameHint: "坚果云邮箱",
            passwordHint: "应用密码（非登录密码）",
            notes: [
                "需要在网页端生成应用密码",
                "登录坚果云网页 → 账户信息 → 安全选项 → 添加应用",
                "使用生成的应用密码，不是登录密码"
            ]
        ),
        ServiceConfig(
            name: "群晖 Synology",
            icon: "externaldrive.fill",
            serverFormat: "http://你的IP:5005/",
            example: "http://192.168.1.10:5005/",
            usernameHint: "群晖用户名",
            passwordHint: "群晖密码",
            notes: [
                "需要在 DSM 中启用 WebDAV",
                "控制面板 → 文件服务 → 启用 WebDAV",
                "HTTP 端口默认 5005，HTTPS 端口 5006"
            ]
        ),
        ServiceConfig(
            name: "Nextcloud",
            icon: "cloud.fill",
            serverFormat: "https://你的服务器/remote.php/dav/files/用户名/",
            example: "https://cloud.example.com/remote.php/dav/files/john/",
            usernameHint: "Nextcloud 用户名",
            passwordHint: "Nextcloud 密码或应用密码",
            notes: [
                "建议使用应用密码",
                "设置 → 安全 → 创建新应用密码"
            ]
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(services) { service in
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: service.icon)
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text(service.name)
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("服务器地址格式：")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(service.serverFormat)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(8)
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(6)
                                
                                Text("示例：")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(service.example)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(service.notes, id: \.self) { note in
                                    HStack(alignment: .top, spacing: 6) {
                                        Text("•")
                                            .foregroundColor(.orange)
                                        Text(note)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("WebDAV 配置指南")
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

struct ServiceConfig: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let serverFormat: String
    let example: String
    let usernameHint: String
    let passwordHint: String
    let notes: [String]
}

#Preview {
    WebDAVServiceGuide()
}

