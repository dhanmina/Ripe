import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginItemManager: LoginItemManager

    var body: some View {
        Form {
            Toggle(isOn: Binding(
                get: { loginItemManager.isEnabled },
                set: { loginItemManager.setEnabled($0) }
            )) {
                Text("Launch at Login")
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}

#Preview {
    SettingsView(loginItemManager: LoginItemManager())
}
