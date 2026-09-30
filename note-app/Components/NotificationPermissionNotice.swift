import SwiftUI
import UIKit
import UserNotifications

struct NotificationPermissionNotice: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @State private var status: UNAuthorizationStatus = .notDetermined

    var body: some View {
        Group {
            if status == .denied {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Notifications are turned off", systemImage: "bell.slash.fill")
                        .foregroundStyle(.orange)

                    Text("Reminders won't alert you until you allow notifications for Backlog.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .buttonStyle(.borderless)
                }
                .padding(.vertical, 4)
            }
        }
        .task(id: scenePhase) {
            status = await NotificationService.authorizationStatus()
        }
    }
}
