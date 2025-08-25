import SwiftUI
import CoreData

struct RoutineReorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var viewModel: HabitViewModel
    
    @FetchRequest(
        entity: Routine.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Routine.orderIndex, ascending: true)],
        animation: .default
    )
    private var routines: FetchedResults<Routine>

    @State private var routineList: [Routine] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(routineList, id: \.self) { routine in
                    Text(routine.name ?? "Unnamed Routine")
                }
                .onMove(perform: moveRoutines)
            }
            .navigationTitle("Reorder Routines")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveOrder()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onAppear {
                routineList = routines.map { $0 }
            }
        }
    }
    
    private func moveRoutines(indices: IndexSet, newOffset: Int) {
        routineList.move(fromOffsets: indices, toOffset: newOffset)
    }
    
    private func saveOrder() {
        for (index, routine) in routineList.enumerated() {
            routine.orderIndex = Int64(index)
        }
        try? context.save()
        viewModel.fetchRoutines() // Refresh the list
    }
}
