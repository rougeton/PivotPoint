import SwiftUI
import CoreData
import PhotosUI

struct EnhancedAddSpotWaypointView: View {
    @ObservedObject var report: DTAReport
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var spotType = ""
    @State private var spotDescription = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var attachedPhotoData: Data?
    @State private var showingCamera = false
    @State private var showCameraUnavailableAlert = false
    @State private var isInitialized = false
    
    private let spotTypeOptions = [
        "Safe Zone",
        "Equipment Cache",
        "Danger Tree",
        "NWZ (No Work Zone)",
        "Medic",
        "Staging",
        "Heavy Equipment Staging",
        "Helicopter Staging",
        "Burn Pit",
        "Pump Site",
        "Water Source (for water truck refill)",
        "Camp Site",
        "Helipad/Spot",
        "ICP",
        "Fuel or Gear Cache"
    ]
    
    var spotLabel: String {
        let waypoints = report.waypointsArray
        let existingSpots = waypoints.filter { waypoint in
            waypoint.label?.starts(with: "Spot") == true
        }
        let spotNumber = existingSpots.count + 1
        
        if spotType.isEmpty {
            return "Spot \(spotNumber)"
        } else {
            return "Spot \(spotNumber) - \(spotType)"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                spotTypeSection
                descriptionSection
                photoSection
                previewSection
            }
            .navigationTitle("Add Spot Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .fullScreenCover(isPresented: $showingCamera) {
                cameraView
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                handlePhotoSelection(newItem)
            }
            .alert("Camera Not Available", isPresented: $showCameraUnavailableAlert) {
                Button("OK") {}
            } message: {
                Text("This device does not have a camera available.")
            }
        }
        .onAppear {
            initializeView()
        }
    }
    
    // MARK: - View Components
    
    private var spotTypeSection: some View {
        Section("Spot Type") {
            spotTypePicker
            if spotType == "Other" {
                otherSpotTypeField
            }
        }
    }
    
    private var spotTypePicker: some View {
        Picker("Select Spot Type", selection: $spotType) {
            Text("Select Type...").tag("")
            ForEach(spotTypeOptions, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(.menu)
    }
    
    private var otherSpotTypeField: some View {
        TextField("Specify spot type", text: $spotDescription)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    private var descriptionSection: some View {
        Section("Description") {
            descriptionEditor
            descriptionHint
        }
    }
    
    private var descriptionEditor: some View {
        TextEditor(text: $spotDescription)
            .frame(height: 80)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
    
    private var descriptionHint: some View {
        Text("Describe the spot location and any relevant details")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private var photoSection: some View {
        Section("Photo (Optional but Recommended)") {
            if hasAttachedPhoto {
                attachedPhotoView
            } else {
                photoSelectionView
            }
        }
    }
    
    private var attachedPhotoView: some View {
        VStack {
            if let data = attachedPhotoData,
               let uiImage = UIImage(data: data) {
                photoImageView(uiImage)
                photoLabelView
                removePhotoButton
            }
        }
    }
    
    private func photoImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .cornerRadius(8)
    }
    
    private var photoLabelView: some View {
        Text("Photo will be labeled: \"\(spotLabel).jpg\"")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 4)
    }
    
    private var removePhotoButton: some View {
        Button("Remove Photo", role: .destructive) {
            removePhoto()
        }
    }
    
    private var photoSelectionView: some View {
        VStack(spacing: 12) {
            takePhotoButton
            photoLibrarySection
            photoHint
        }
    }
    
    private var takePhotoButton: some View {
        Button(action: handleTakePhotoTap) {
            photoButtonContent(icon: "camera", text: "Take Photo", color: .blue)
        }
    }
    
    private var photoLibrarySection: some View {
        VStack {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                photoButtonContent(icon: "photo.on.rectangle", text: "Choose from Library", color: .green)
            }
        }
    }
    
    private func photoButtonContent(icon: String, text: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var photoHint: some View {
        Text("📸 Adding a photo helps identify the spot location")
            .font(.caption)
            .foregroundColor(.orange)
            .multilineTextAlignment(.center)
    }
    
    private var previewSection: some View {
        Section("Preview") {
            previewContent
        }
    }
    
    private var previewContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Spot Label:")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(spotLabel)
                .font(.headline)
                .foregroundColor(.orange)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            cancelButton
        }
        ToolbarItem(placement: .confirmationAction) {
            addButton
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private var addButton: some View {
        Button("Add Spot") {
            addSpotAndDismiss()
        }
        .disabled(shouldDisableAddButton)
    }
    
    private var cameraView: some View {
        ImagePicker(sourceType: .camera) { data in
            handleCameraResult(data)
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasAttachedPhoto: Bool {
        attachedPhotoData != nil
    }
    
    private var shouldDisableAddButton: Bool {
        !isInitialized || spotType.isEmpty
    }
    
    // MARK: - Methods
    
    private func initializeView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInitialized = true
        }
    }
    
    private func handleTakePhotoTap() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showingCamera = true
        } else {
            showCameraUnavailableAlert = true
        }
    }
    
    private func handleCameraResult(_ data: Data?) {
        attachedPhotoData = data
    }
    
    private func handlePhotoSelection(_ newItem: PhotosPickerItem?) {
        Task {
            do {
                if let data = try await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.attachedPhotoData = data
                    }
                }
            } catch {
                print("Failed to load photo: \(error)")
            }
        }
    }
    
    private func removePhoto() {
        attachedPhotoData = nil
        selectedPhotoItem = nil
    }
    
    private func addSpotAndDismiss() {
        guard isInitialized else { return }
        
        let finalLabel = spotLabel
        let finalDescription = createFinalDescription()
        
        let newWaypoint = createWaypoint(label: finalLabel, description: finalDescription)
        
        if let photoData = attachedPhotoData {
            createPhotoAttachment(with: photoData, label: finalLabel)
        }
        
        saveAndDismiss()
    }
    
    private func createFinalDescription() -> String {
        if spotType == "Other" {
            return spotDescription
        } else if spotDescription.isEmpty {
            return spotType
        } else {
            return "\(spotType): \(spotDescription)"
        }
    }
    
    private func createWaypoint(label: String, description: String) -> DTAWaypoint {
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.latitude = LocationHelper.shared.currentLatitude
        newWaypoint.longitude = LocationHelper.shared.currentLongitude
        newWaypoint.label = label
        newWaypoint.locationNotes = description
        newWaypoint.isSpotPoint = true
        newWaypoint.dtaReport = report
        return newWaypoint
    }
    
    private func createPhotoAttachment(with data: Data, label: String) {
        let attachment = MediaAttachment(context: viewContext)
        attachment.id = UUID()
        attachment.mediaType = "photo"
        attachment.photoTimestamp = Date()
        
        let sanitizedLabel = sanitizeFileName(label)
        attachment.fileName = "\(sanitizedLabel).jpg"
        
        savePhotoToDisk(data: data, attachment: attachment)
        attachment.dtaReport = report
    }
    
    private func sanitizeFileName(_ fileName: String) -> String {
        // Remove or replace characters that are not filesystem-safe
        let invalidCharacters = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return fileName
            .components(separatedBy: invalidCharacters)
            .joined(separator: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
    
    private func savePhotoToDisk(data: Data, attachment: MediaAttachment) {
        guard let docsUrl = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first,
        let fileName = attachment.fileName else {
            print("Failed to get documents directory or filename")
            return
        }
        
        let fileUrl = docsUrl.appendingPathComponent(fileName)
        do {
            try data.write(to: fileUrl)
            attachment.fileURL = fileUrl.absoluteString
        } catch {
            print("Failed to write image data to disk: \(error)")
        }
    }
    
    private func saveAndDismiss() {
        do {
            try viewContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        } catch {
            print("Failed to save new spot waypoint: \(error.localizedDescription)")
            dismiss()
        }
    }
}
