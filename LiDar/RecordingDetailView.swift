import SwiftUI
import SceneKit

struct RecordingDetailView: View {
    var body: some View {
        SceneView(scene: loadScene(), options: [.allowsCameraControl, .autoenablesDefaultLighting])
            .edgesIgnoringSafeArea(.all)
    }

    func loadScene() -> SCNScene {
        // Load and return a 3D Scene
        return SCNScene()
    }
}
