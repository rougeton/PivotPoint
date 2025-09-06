import SwiftUI
import PhotosUI

struct MainMenuView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var selectedWatermark: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showUserInfoEditor = false
    @State private var showMoreOptions = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Layer 1: Watermark
                GeometryReader { geometry in
                    let watermarkImage = selectedWatermark ?? UIImage(named: "NewAppLogo")
                    
                    if let uiImage = watermarkImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .opacity(0.9)
                            .shadow(color: .white.opacity(0.6), radius: 20)
                            .shadow(color: .orange.opacity(0.3), radius: 40)
                            .shadow(color: .red.opacity(0.2), radius: 10)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .onLongPressGesture(minimumDuration: 3) {
                                showPhotoPicker = true
                            }
                            .onTapGesture(count: 2) {
                                selectedWatermark = nil
                            }
                    }
                }
                
                // MARK: - Layer 2: Main UI Content
                VStack(spacing: 0) {
                    HeaderView()
                        .environmentObject(userSettings)
                    
                    Spacer()
                    
                    ProfileStatusView()
                        .padding(.bottom, 4)
                    
                    // MARK: - Bottom Footer Menu
                    HStack {
                        // This is the updated line
                        HoverButtonView(systemImageName: "flame.circle", label: "Fire Logs", destination: FireCenterListView())
                        
                        HoverButtonView(systemImageName: "books.vertical", label: "References", destination: ReferencesView())
                        HoverButtonView(systemImageName: "checkmark.seal", label: "Certs", destination: CertificationView())
                        HoverButtonView(systemImageName: "square.and.arrow.up", label: "Export", destination: ExportView())
                      
                        Button(action: { showMoreOptions = true }) {
                            VStack {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                Text("More")
                                    .font(.caption)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .sheet(isPresented: $showUserInfoEditor) {
                UserInfoEntryView()
                    .environmentObject(userSettings)
            }
            .confirmationDialog("More Options", isPresented: $showMoreOptions) {
                Button("Edit User Profile") {
                    showUserInfoEditor = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let item = newItem,
                       let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedWatermark = image
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


// MARK: - Profile Status View
struct ProfileStatusView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        Text(formattedUserInfo())
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(.thinMaterial, in: Capsule())
            .padding(.bottom, 8)
    }
    
    private func formattedUserInfo() -> String {
        var parts: [String] = []
        if !userSettings.userName.isEmpty { parts.append(userSettings.userName) }
        if !userSettings.callSign.isEmpty { parts.append(userSettings.callSign) }
        if !userSettings.crewName.isEmpty { parts.append(userSettings.crewName) }
        
        return parts.isEmpty ? "No Profile Set" : parts.joined(separator: " • ")
    }
}
