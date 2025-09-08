import SwiftUI
import PhotosUI

struct WaypointsListView: View {
    @ObservedObject var viewModel: DTAReportViewModel
        
    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // List content with proper spacing
            List {
                // Spacer section to push content below header
                Section(header: Spacer(minLength: 200)) {
                    EmptyView()
                }

                Section("Waypoints") {
                    // Use waypointsArray from viewModel
                    ForEach(viewModel.waypointsArray, id: \.objectID) { waypoint in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(waypoint.label ?? "Unnamed Waypoint").font(.headline)
                                Text(waypoint.ddmCoordinateString).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let waypoint = viewModel.waypointsArray[index]
                            // Remove waypoint from context
                            viewModel.context.delete(waypoint)
                            viewModel.saveContext()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}

struct PhotosListView: View {
    @ObservedObject var viewModel: DTAReportViewModel
        
    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Content with proper spacing
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer for header
                    Spacer(minLength: 200)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                        // Use images array from viewModel
                        ForEach(viewModel.images) { image in
                            VStack {
                                Image(uiImage: image.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
                                    .cornerRadius(8)
                                Button("Delete") {
                                    // Remove the media attachment
                                    viewModel.removeMediaAttachment(image.mediaAttachment)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}

struct SpotWaypointSheet: View {
    let latitude: Double
    let longitude: Double
    
    @State private var label: String = ""
    @State private var notes: String = ""
    
    let onSave: (Double, Double, String, String) -> Void
    let onCancel: () -> Void
        
    var body: some View {
        NavigationView {
            Form {
                Section("Location") {
                    HStack {
                        Text("Latitude:")
                        Spacer()
                        Text(String(format: "%.6f", latitude)).foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Longitude:")
                        Spacer()
                        Text(String(format: "%.6f", longitude)).foregroundColor(.secondary)
                    }
                }
                Section("Waypoint Details") {
                    TextField("Label (e.g., 'Spot 1', 'Pump Site')", text: $label)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Spot Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(latitude, longitude, label, notes)
                    }
                    .disabled(label.isEmpty)
                }
            }
        }
    }
}
