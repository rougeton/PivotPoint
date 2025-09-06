import SwiftUI
import PhotosUI

struct PhotosSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    @State private var selectedPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        Section(header: Text("Photos (\(viewModel.images.count))")) {
            if viewModel.isLoadingPhotos {
                ProgressView("Processing...")
            }
            
            ForEach(viewModel.images) { image in
                PhotoRow(identifiableImage: image, viewModel: viewModel)
            }
            
            PhotosPicker(selection: $selectedPickerItems, maxSelectionCount: 10, matching: .images) {
                Label("Add Photos", systemImage: "plus.square.on.square")
            }
            .onChange(of: selectedPickerItems) { _, newItems in
                if !newItems.isEmpty {
                    viewModel.processPhotos(newItems)
                    selectedPickerItems.removeAll()
                }
            }
        }
    }
}

struct PhotoRow: View {
    let identifiableImage: IdentifiableImage
    @ObservedObject var viewModel: DTAReportViewModel
    
    var body: some View {
        HStack {
            Image(uiImage: identifiableImage.image)
                .resizable().scaledToFit().frame(height: 60)
            Text(identifiableImage.mediaAttachment.fileName ?? "Photo").lineLimit(1)
            Spacer()
            Button(role: .destructive) {
                viewModel.removeImage(identifiableImage)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
        }
    }
}
