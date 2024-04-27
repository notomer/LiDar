import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OnboardingPageView(
                imageSystemName: "camera.viewfinder",
                title: "Welcome to AR Explorer!",
                subtitle: "Discover your world in 3D.",
                description: "Swipe right to learn more about how this app works and why it needs camera access.",
                color: .blue,
                index: 0
            )
            
            OnboardingPageView(
                imageSystemName: "cube.transparent",
                title: "Real-time 3D Mesh",
                subtitle: "Visualize your surroundings.",
                description: "This app uses the LiDAR sensor and camera to create a live 3D mesh of your environment.",
                color: .green,
                index: 1
            )
            
            OnboardingPageView(
                imageSystemName: "hand.raised.fill",
                title: "We Need Camera Access",
                subtitle: "Permission required to proceed.",
                description: "Please grant camera access to fully utilize the functionality of the app.",
                color: .purple,
                index: 2,
                requestPermission: { requestCameraPermissions() }
            )
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .animation(.easeInOut, value: selectedTab)
    }

    private func requestCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    isOnboardingComplete = true
                } else {
                    // If permissions are denied, alert the user that they need to enable it in settings
                    if selectedTab == 2 {
                        selectedTab += 1 // Advance to the next screen explaining how to enable permissions
                    }
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageSystemName: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    let index: Int
    var requestPermission: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(color)
                .padding()

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 1)

            Text(subtitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(description)
                .padding()
                .multilineTextAlignment(.center)

            if index == 2 { // Only show the button on the last informational page
                Button("Grant Camera Access", action: {
                    requestPermission?()
                })
                .foregroundColor(.white)
                .padding()
                .background(color)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .tag(index)
    }
}
