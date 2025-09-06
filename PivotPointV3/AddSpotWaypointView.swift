import SwiftUI
import CoreData
import PhotosUI

struct AddSpotWaypointView: View {
    @ObservedObject var report: DTAReport
    // --- FIX: Gets the context from the environment instead of the initializer ---
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var comment = ""
    @State private var spotPhotoPickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var attachedPhotoData: Data?
    @State private var showCameraUnavailableAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section("Spot Details") {
                    TextField("Comment (e.g., spot fire, pump site)", text: $comment)
                }
                
                Section("Attach Photo (Optional)") {
                    if let data = attachedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                        Button("Remove Photo", role: .destructive) {
                            attachedPhotoData = nil
                        }
                    } else {
                        Button("Take Photo") {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showingCamera = true
                            } else {
                                showCameraUnavailableAlert = true
                            }
                        }
                        PhotosPicker("Choose from Library", selection: $spotPhotoPickerItem, matching: .images)
                    }
                }
            }
            .navigationTitle("Add Spot Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSpotAndDismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera) { imageData in
                    self.attachedPhotoData = imageData
                }
            }
            .onChange(of: spotPhotoPickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        self.attachedPhotoData = data
                    }
                }
            }
            .alert("Camera Not Available", isPresented: $showCameraUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This device does not have a camera available.")
            }
        }
    }
    
    private func addSpotAndDismiss() {
        let spotLabel = "Spot \(report.waypointsArray.filter { $0.label?.starts(with: "Spot") == true }.count + 1)"
        
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.latitude = LocationHelper.shared.currentLatitude
        newWaypoint.longitude = LocationHelper.shared.currentLongitude
        newWaypoint.label = spotLabel
        newWaypoint.locationNotes = comment
        newWaypoint.isSpotPoint = true
        newWaypoint.dtaReport = report
        
        if let data = attachedPhotoData {
            let attachment = MediaAttachment(context: viewContext)
            attachment.id = UUID()
            attachment.mediaType = "photo"
            attachment.photoTimestamp = Date()
            
            let sanitizedComment = sanitizeForFileName(comment)
            let finalFileName: String
            if sanitizedComment.isEmpty {
                finalFileName = "\(spotLabel).jpg"
            } else {
                finalFileName = "\(spotLabel) - \(sanitizedComment).jpg"
            }
            attachment.fileName = finalFileName
            
            if let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileUrl = docsUrl.appendingPathComponent(finalFileName)
                do {
                    try data.write(to: fileUrl)
                    attachment.fileURL = fileUrl.absoluteString
                } catch {
                    print("Failed to write image data to disk: \(error)")
                }
            }
            attachment.dtaReport = report
        }
        
        do {
            try viewContext.save()
            print("Successfully saved Spot waypoint and photo attachment.")
        } catch {
            print("Failed to save new spot waypoint: \(error.localizedDescription)")
        }
        
        dismiss()
    }
    
    private func sanitizeForFileName(_ string: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return string.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}
