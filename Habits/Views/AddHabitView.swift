//
//  AddHabitView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/21/25.
//

import SwiftUI
import CoreData

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: HabitViewModel

    @FetchRequest(
        entity: Area.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Area.name, ascending: true)],
        animation: .default
    )
    private var areas: FetchedResults<Area>

    @FetchRequest(
        entity: Routine.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Routine.name, ascending: true)],
        animation: .default
    )
    private var routines: FetchedResults<Routine>
    
    @State private var habitName: String = ""
    @State private var selectedArea: Area?
    @State private var selectedRoutine: Routine?
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Habit Name", text: $habitName)
                
                Picker("Area", selection: $selectedArea) {
                    ForEach(areas, id: \.self) { area in
                        Text(area.name ?? "Unnamed Area").tag(area as Area?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Routine", selection: $selectedRoutine) {
                    ForEach(routines, id: \.self) { routine in
                        Text(routine.name ?? "Unnamed Routine").tag(routine as Routine?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .navigationTitle("New Habit")
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
                        if let area = selectedArea {
                            viewModel.addHabit(name: habitName, area: area, routine: selectedRoutine)
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(areas.isEmpty || habitName.isEmpty)
                }
            }
        }
    }
}
