import Foundation
import SwiftData

@Model
final class WebDAVAccount {
    @Attribute(.unique) var id: UUID
    var name: String
    var serverURL: String
    var username: String
    var lastSyncDate: Date?
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        serverURL: String,
        username: String,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.serverURL = serverURL
        self.username = username
        self.isActive = isActive
    }
}

