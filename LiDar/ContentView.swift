import SwiftUI
import ARKit

struct ContentView: View {
    @State private var isSessionRunning = true

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(isSessionRunning: $isSessionRunning)
            VStack {
                Spacer()
                Button(action: {
                    isSessionRunning = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isSessionRunning = true
                    }
                }) {
                    Text("Reset AR Session")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var isSessionRunning: Bool
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification
        configuration.planeDetection = [.horizontal, .vertical]
        if isSessionRunning {
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            uiView.session.pause()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let meshAnchor = anchor as? ARMeshAnchor else { return }
            let meshNode = createMeshNode(using: meshAnchor)
            node.addChildNode(meshNode)
        }
        
        private func createMeshNode(using meshAnchor: ARMeshAnchor) -> SCNNode {
            let vertices = meshAnchor.geometry.vertices
            let vertexBuffer = vertices.buffer
            let vertexCount = vertices.count
            let vertexStride = vertices.stride
            let vertexSource = SCNGeometrySource(buffer: vertexBuffer,
                                                 vertexFormat: vertices.format,
                                                 semantic: .vertex,
                                                 vertexCount: vertexCount,
                                                 dataOffset: 0,
                                                 dataStride: vertexStride)
            
            let faces = meshAnchor.geometry.faces
            let indexData = Data(bytesNoCopy: faces.buffer.contents(),
                                 count: faces.buffer.length,
                                 deallocator: .none)
            let element = SCNGeometryElement(data: indexData,
                                             primitiveType: .triangles,
                                             primitiveCount: faces.count,
                                             bytesPerIndex: faces.bytesPerIndex)
            
            let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)  // Semi-transparent blue
            geometry.materials = [material]
            
            return SCNNode(geometry: geometry)
        }
        
    }
}
