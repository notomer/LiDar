import SwiftUI

@main
struct LiDARApp: App {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false

    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ScanRecorderView()
                .tabItem {
                    Label("New Recording", systemImage: "dot.radiowaves.left.and.right")
                }
            RecordingsListView()
                .tabItem {
                    Label("Recordings", systemImage: "list.bullet")
                }
        }
    }
}
