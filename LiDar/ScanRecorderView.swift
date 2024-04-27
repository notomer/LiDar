import SwiftUI
import ARKit

struct ScanRecorderView: View {
    @State private var isRecording = false

    var body: some View {
        VStack {
            ARSessionViewContainer(isRecording: $isRecording)
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                isRecording.toggle()
            }
            .padding()
            .foregroundColor(.white)
            .background(isRecording ? Color.red : Color.green)
            .cornerRadius(10)
        }
    }
}

struct ARSessionViewContainer: UIViewRepresentable {
    @Binding var isRecording: Bool

    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView()
        if isRecording {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
            }
            view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        return view
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if isRecording {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            configuration.sceneReconstruction = .mesh
            uiView.session.run(configuration)
        } else {
            uiView.session.pause()
        }
    }

    typealias UIViewType = ARSCNView
}
