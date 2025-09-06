// MARK: - SaveButtonSectionView.swift
import SwiftUI

struct SaveButtonSectionView: View {
    var isFormValid: Bool
    var saveAction: () -> Void
    var cancelAction: () -> Void

    var body: some View {
        HStack {
            Button("Cancel", action: cancelAction)
                .buttonStyle(.bordered)
            Spacer()
            Button("Save DTA Report", action: saveAction)
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
        }
        .padding(.vertical)
    }
}
