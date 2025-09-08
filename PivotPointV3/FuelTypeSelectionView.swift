import SwiftUI
import CoreData

struct FuelTypeSelectionView: View {
    @ObservedObject var report: DTAReport
    let context: NSManagedObjectContext
    let viewModel: DTAReportViewModel?

    private var selections: [FuelTypeSelection] {
        (report.fuelTypes as? Set<FuelTypeSelection> ?? []).sorted { $0.fuelType ?? "" < $1.fuelType ?? "" }
    }
    
    private var totalPercentage: Int {
        selections.reduce(0) { $0 + Int($1.percentage) }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Form content with proper spacing
            Form {
                // Spacer section to push content below header
                Section(header: Spacer(minLength: 200)) {
                    EmptyView()
                }
            Section("Select Fuel Types") {
                ForEach(selections) { selection in
                    fuelTypeRow(for: selection)
                }
                
                if DTAPicklists.fuelTypeOptions.count > selections.count {
                    Menu("Add Fuel Type...") {
                        ForEach(DTAPicklists.fuelTypeOptions.filter { option in
                            !selections.contains { $0.fuelType == option }
                        }, id: \.self) { option in
                            Button(option) {
                                withAnimation {
                                    toggleSelection(for: option)
                                }
                            }
                        }
                    }
                }
            }
            
            if selections.count > 1 {
                Section("Total Percentage") {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text("\(totalPercentage)%")
                            .foregroundColor(totalPercentage == 100 ? .green : .red)
                    }
                    if totalPercentage != 100 {
                        Text("Percentages must total 100%").font(.caption).foregroundColor(.red)
                    }
                }
            }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
    
    @ViewBuilder
    private func fuelTypeRow(for selection: FuelTypeSelection) -> some View {
        VStack {
            HStack {
                Text(selection.fuelType ?? "Unknown")
                Spacer()
                Button(role: .destructive) {
                    withAnimation {
                        toggleSelection(for: selection.fuelType ?? "")
                    }
                } label: { Image(systemName: "xmark.circle.fill") }
            }
            .buttonStyle(.plain)
            
            if selections.count > 1 {
                Picker("Percentage", selection: Binding(
                    get: { selection.percentage },
                    set: { newValue in
                        updatePercentage(for: selection, to: newValue)
                    }
                )) {
                    Text("25%").tag(Int16(25))
                    Text("50%").tag(Int16(50))
                    Text("75%").tag(Int16(75))
                }
                .pickerStyle(.segmented)
                .padding(.top, 5)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleSelection(for option: String) {
        // Manually notify observers that the report object will change.
        report.objectWillChange.send()
        
        let mutableFuelTypes = report.mutableSetValue(forKey: "fuelTypes")
        
        if let selectionToRemove = selections.first(where: { $0.fuelType == option }) {
            mutableFuelTypes.remove(selectionToRemove)
            context.delete(selectionToRemove)
        } else {
            let newSelection = FuelTypeSelection(context: context)
            newSelection.id = UUID()
            newSelection.fuelType = option
            newSelection.percentage = 0
            newSelection.dtaReport = report
            mutableFuelTypes.add(newSelection)
        }
        
        let currentSelections = mutableFuelTypes.allObjects as! [FuelTypeSelection]
        if currentSelections.count == 1 {
            currentSelections[0].percentage = 100
        } else if currentSelections.count > 1 {
            let basePercentage = 100 / currentSelections.count
            let remainder = 100 % currentSelections.count
            for (i, item) in currentSelections.sorted(by: { $0.fuelType ?? "" < $1.fuelType ?? "" }).enumerated() {
                item.percentage = Int16(basePercentage + (i < remainder ? 1 : 0))
            }
        }
        
        try? context.save()

        // Trigger immediate UI update in the parent view
        viewModel?.refreshFuelTypes()
    }
    
    private func updatePercentage(for selection: FuelTypeSelection, to newValue: Int16) {
        // Manually notify observers for instant feedback.
        report.objectWillChange.send()
        
        selection.percentage = newValue
        let currentSelections = self.selections
        
        if currentSelections.count == 2 {
            if let otherSelection = currentSelections.first(where: { $0.id != selection.id }) {
                otherSelection.percentage = 100 - newValue
            }
        } else if currentSelections.count > 2 {
            let otherSelections = currentSelections.filter { $0.id != selection.id }
            
            let remainingPercentage = 100 - Int(newValue)
            let numberOfOthers = otherSelections.count
            
            if numberOfOthers > 0 {
                let base = remainingPercentage / numberOfOthers
                let remainder = remainingPercentage % numberOfOthers
                for (i, item) in otherSelections.enumerated() {
                    item.percentage = Int16(base + (i < remainder ? 1 : 0))
                }
            }
        }
        
        try? context.save()
    }
}
