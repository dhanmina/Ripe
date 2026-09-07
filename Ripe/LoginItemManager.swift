import Combine
import Foundation
import ServiceManagement

final class LoginItemManager: ObservableObject {
    @Published private(set) var isEnabled: Bool

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // SMAppService can refuse (e.g. user declined in System Settings);
            // fall through and resync from the actual status either way.
        }
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
