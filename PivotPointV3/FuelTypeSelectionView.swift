import SwiftUI
import CoreData

struct FuelTypeSelectionView: View {
    @ObservedObject var report: DTAReport
    let context: NSManagedObjectContext
    
    @State private var selections: [FuelTypeSelection] = []
    @State private var isUpdatingPercentages = false // Flag to prevent infinite loops
    
    private var totalPercentage: Int {
        selections.reduce(0) { $0 + Int($1.percentage) }
    }

    var body: some View {
        Form {
            Section("Select Fuel Types") {
                ForEach(selections.indices, id: \.self) { index in
                    fuelTypeRow(for: index)
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
                        Text("Percentages must total 100%")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Fuel Types")
        .onAppear(perform: loadSelections)
        .onDisappear(perform: saveSelections)
    }
    
    @ViewBuilder
    private func fuelTypeRow(for index: Int) -> some View {
        VStack {
            HStack {
                Text(selections[index].fuelType ?? "Unknown")
                Spacer()
                Button(role: .destructive) {
                    withAnimation {
                        toggleSelection(for: selections[index].fuelType ?? "")
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .buttonStyle(PressedHighlightButtonStyle())
            
            if selections.count > 1 {
                Picker("Percentage", selection: Binding(
                    get: { selections[index].percentage },
                    set: { newValue in
                        updatePercentage(at: index, to: newValue)
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
    
    private func loadSelections() {
        let set = report.fuelTypes as? Set<FuelTypeSelection> ?? []
        self.selections = Array(set).sorted { $0.fuelType ?? "" < $1.fuelType ?? "" }
    }
    
    private func saveSelections() {
        let currentSet = report.fuelTypes as? Set<FuelTypeSelection> ?? Set()
        for item in currentSet {
            if !selections.contains(item) {
                context.delete(item)
            }
        }
        report.fuelTypes = NSSet(array: selections)
    }
    
    private func toggleSelection(for option: String) {
        if let index = selections.firstIndex(where: { $0.fuelType == option }) {
            let itemToDelete = selections[index]
            selections.remove(at: index)
            if itemToDelete.isInserted || context.registeredObjects.contains(itemToDelete) {
                context.delete(itemToDelete)
            }
        } else {
            let newSelection = FuelTypeSelection(context: context)
            newSelection.id = UUID()
            newSelection.fuelType = option
            newSelection.percentage = 0
            newSelection.dtaReport = report
            selections.append(newSelection)
        }
        
        // Set initial percentages when adding/removing items
        if selections.count == 1 {
            selections[0].percentage = 100
        } else if selections.count == 2 {
            selections[0].percentage = 50
            selections[1].percentage = 50
        } else if selections.count > 2 {
            // For more than 2 selections, distribute evenly
            let basePercentage = Int16(100 / selections.count)
            let remainder = Int16(100 % selections.count)
            
            for i in selections.indices {
                selections[i].percentage = basePercentage + (i < remainder ? 1 : 0)
            }
        }
        
        selections.sort { $0.fuelType ?? "" < $1.fuelType ?? "" }
    }
    
    // FIXED: Proper complementary percentage update logic
    private func updatePercentage(at index: Int, to newValue: Int16) {
        guard !isUpdatingPercentages && index < selections.count else { return }
        
        isUpdatingPercentages = true
        
        // Update the selected percentage
        selections[index].percentage = newValue
        
        if selections.count == 2 {
            // For exactly 2 selections, they must complement to 100%
            let otherIndex = (index == 0) ? 1 : 0
            let complementValue = Int16(100 - newValue)
            
            // Directly set the complement - it will always be valid since we only allow 25, 50, 75
            // 25 -> 75, 50 -> 50, 75 -> 25
            selections[otherIndex].percentage = complementValue
            
        } else if selections.count > 2 {
            // For more than 2 selections, distribute remaining percentage evenly among others
            let remainingPercentage = Int16(100 - newValue)
            let numberOfOthers = Int16(selections.count - 1)
            
            if numberOfOthers > 0 {
                let basePercentage = remainingPercentage / numberOfOthers
                let remainder = remainingPercentage % numberOfOthers
                
                var distributedCount: Int16 = 0
                for i in selections.indices {
                    if i != index {
                        // Give base percentage plus 1 extra to first 'remainder' number of items
                        selections[i].percentage = basePercentage + (distributedCount < remainder ? 1 : 0)
                        distributedCount += 1
                    }
                }
            }
        }
        
        // Small delay to ensure UI updates properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isUpdatingPercentages = false
        }
    }
}
