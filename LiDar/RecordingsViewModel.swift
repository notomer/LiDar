import SwiftUI

struct Recording: Identifiable, Codable {
    var id: UUID
    var name: String
    var timestamp: Date
    var previewImagePath: String
}

class RecordingsViewModel: ObservableObject {
    @Published var recordings: [Recording] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        loadRecordings()
    }

    func loadRecordings() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let recordingsPath = documentsPath.appendingPathComponent("recordings")

            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: recordingsPath, includingPropertiesForKeys: nil)
                // Assuming files are stored with relevant metadata or filenames contain necessary info
                let recordings = fileURLs.map { url -> Recording in
                    // Example of extracting name and date from filename
                    let recordingName = url.deletingPathExtension().lastPathComponent
                    let timestamp = Date() // Assuming you need to extract this differently
                    return Recording(id: UUID(), name: recordingName, timestamp: timestamp, previewImagePath: url.path)
                }
                DispatchQueue.main.async {
                    self.recordings = recordings
                    self.isLoading = false
                }
            } catch {
                print("Error loading recordings: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to load recordings"
                }
            }
        }
    }
    func deleteRecording(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let recording = recordings[index]
            // Implement actual delete logic here
            // Update UI after deletion
            DispatchQueue.main.async {
                self.recordings.remove(at: index)
            }
        }
    }

    func exportRecording(_ recording: Recording) {
        // Placeholder for export functionality
        print("Exporting recording: \(recording.name)")
        // You would typically use UIActivityViewController here in a UIKit context
    }
}
