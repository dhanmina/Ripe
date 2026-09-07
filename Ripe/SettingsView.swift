import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginItemManager: LoginItemManager

    var body: some View {
        Toggle(isOn: Binding(
            get: { loginItemManager.isEnabled },
            set: { loginItemManager.setEnabled($0) }
        )) {
            Text("Launch at Login")
        }
        .toggleStyle(.switch)
    }
}

#Preview {
    SettingsView(loginItemManager: LoginItemManager())
}
