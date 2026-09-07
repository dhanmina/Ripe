import Combine
import Foundation
import ServiceManagement

final class LoginItemManager: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var lastErrorMessage: String?

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        lastErrorMessage = nil
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            lastErrorMessage = "macOS blocked this change. Check Login Items in System Settings."
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
