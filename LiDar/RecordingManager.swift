import Foundation
import ARKit
import SceneKit

class RecordingManager: NSObject, ARSessionDelegate {
    private var arSession = ARSession()
    private var scnScene = SCNScene()
    private var isRecording = false

    override init() {
        super.init()
        arSession.delegate = self
    }

    func startRecording() {
        guard !isRecording else { return }
        isRecording = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func stopAndSaveRecording() {
        guard isRecording else { return }
        isRecording = false
        arSession.pause()

        // Save the scene to file
        saveSceneToFile()
    }

    // ARSessionDelegate method
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateScene(with: frame)
    }

    private func updateScene(with frame: ARFrame) {
        // As before, implement updating the scene here
        scnScene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

        for anchor in frame.anchors {
            guard let meshAnchor = anchor as? ARMeshAnchor else { continue }
            let geometry = createGeometry(from: meshAnchor)
            let node = SCNNode(geometry: geometry)
            node.transform = SCNMatrix4(meshAnchor.transform)
            scnScene.rootNode.addChildNode(node)
        }
    }

    private func createGeometry(from meshAnchor: ARMeshAnchor) -> SCNGeometry {
        // Accessing vertices
        let vertexBuffer = meshAnchor.geometry.vertices.buffer
        let vertexCount = meshAnchor.geometry.vertices.count
        let vertexStride = meshAnchor.geometry.vertices.stride
        let vertexSource = SCNGeometrySource(buffer: vertexBuffer,
                                             vertexFormat: MTLVertexFormat.float3,
                                             semantic: .vertex,
                                             vertexCount: vertexCount,
                                             dataOffset: 0,
                                             dataStride: vertexStride)

        // Accessing normals
        let normalBuffer = meshAnchor.geometry.normals.buffer
        let normalCount = meshAnchor.geometry.normals.count
        let normalStride = meshAnchor.geometry.normals.stride
        let normalSource = SCNGeometrySource(buffer: normalBuffer,
                                             vertexFormat: MTLVertexFormat.float3,
                                             semantic: .normal,
                                             vertexCount: normalCount,
                                             dataOffset: 0,
                                             dataStride: normalStride)

        // Accessing indices for the faces
        let indexBuffer = meshAnchor.geometry.faces.buffer
        let indexCount = meshAnchor.geometry.faces.count * 3 // Assuming triangles
        let bytesPerIndex = meshAnchor.geometry.faces.bytesPerIndex
        let indexData = Data(bytesNoCopy: indexBuffer.contents(), count: indexCount * bytesPerIndex, deallocator: .none)
        let element = SCNGeometryElement(data: indexData, primitiveType: .triangles, primitiveCount: indexCount / 3, bytesPerIndex: bytesPerIndex)

        // Combine sources and element to create the geometry
        return SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
    }

    private func saveSceneToFile() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("lidarRecording.scn")
        
        scnScene.write(to: fileURL, options: nil, delegate: nil) { (totalProgress, error, stop) in
            if let error = error {
                print("Failed to save SCN file: \(error.localizedDescription)")
            } else {
                print("Saved SCN file successfully.")
            }
        }
    }
}
