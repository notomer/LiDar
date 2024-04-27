import SwiftUI

struct RecordingsListView: View {
    @StateObject var viewModel = RecordingsViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.recordings) { recording in
                    HStack {
                        Image(systemName: "photo") // Placeholder for the preview image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(recording.name)
                                .font(.headline)
                            Text("Date: \(recording.timestamp, formatter: itemFormatter)")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.exportRecording(recording)
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            if let index = viewModel.recordings.firstIndex(where: { $0.id == recording.id }) {
                                viewModel.deleteRecording(at: IndexSet(integer: index))
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
                .onDelete(perform: viewModel.deleteRecording)
            }
            .navigationTitle("Recordings")
            .navigationBarItems(trailing: Button("Reload") {
                viewModel.loadRecordings()
            })
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
        }
    }
}

// Helper to format the date
let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct RecordingsListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsListView()
    }
}
