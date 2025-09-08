import SwiftUI
import PhotosUI
import CoreData

struct PhotosSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingNameDialog = false
    @State private var pendingPhotoData: Data?
    @State private var photoName = ""
    
    var body: some View {
        Section("Media Attachments") {
            // Use the mediaAttachmentsArray from DTAReport extension
            ForEach(viewModel.report.mediaAttachmentsArray, id: \.objectID) { media in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(media.fileName ?? "Media File")
                            .font(.headline)
                        
                        if let mediaType = media.mediaType {
                            Text(mediaType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let photoDate = media.photoDate {
                            Text(photoDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let locationDDM = media.photoLocationDDM, !locationDDM.isEmpty {
                            Text("Location: \(locationDDM)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Delete") {
                        viewModel.removeMediaAttachment(media)
                    }
                    .foregroundColor(.red)
                }
                .padding(.vertical, 4)
            }
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 1,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Photo")
                }
            }
            .onChange(of: selectedPhotos) { _, newPhotos in
                if let photo = newPhotos.first {
                    Task {
                        if let data = try? await photo.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                pendingPhotoData = data
                                photoName = ""
                                showingNameDialog = true
                            }
                        }
                    }
                    selectedPhotos.removeAll()
                }
            }
        }
        .alert("Name Your Photo", isPresented: $showingNameDialog) {
            TextField("What does this photo show?", text: $photoName)
            Button("Save") {
                savePhotoWithName()
            }
            .disabled(photoName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {
                pendingPhotoData = nil
                photoName = ""
            }
        } message: {
            Text("Please provide a descriptive name for this photo (e.g., 'Danger tree near road', 'Equipment staging area')")
        }
    }

    private func savePhotoWithName() {
        guard let data = pendingPhotoData else { return }

        let sanitizedName = sanitizeForFileName(photoName.trimmingCharacters(in: .whitespacesAndNewlines))
        let fileName = sanitizedName.isEmpty ? "Photo_\(Date().timeIntervalSince1970).jpg" : "\(sanitizedName).jpg"

        let attachment = MediaAttachment(context: viewModel.context)
        attachment.id = UUID()
        attachment.mediaType = "photo"
        attachment.photoTimestamp = Date()
        attachment.dtaReport = viewModel.report
        attachment.fileName = fileName

        if let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = docsUrl.appendingPathComponent(fileName)
            do {
                try data.write(to: fileUrl)
                attachment.fileURL = fileUrl.absoluteString
            } catch {
                print("Failed to write image data: \(error)")
            }
        }

        viewModel.saveContext()

        // Clean up
        pendingPhotoData = nil
        photoName = ""
    }

    private func sanitizeForFileName(_ string: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>: ")
        return string.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}
