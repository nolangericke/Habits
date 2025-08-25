//
//  UpdateHabitView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/24/25.
//

import SwiftUI
import CoreData

struct UpdateHabitView: View {
    @ObservedObject var habit: Habit
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: []) var areas: FetchedResults<Area>
    @FetchRequest(sortDescriptors: []) var routines: FetchedResults<Routine>
    
    @State private var name: String = ""
    @State private var selectedArea: Area?
    @State private var selectedRoutine: Routine?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Habit Name")) {
                    TextField("Name", text: $name)
                }
                Section(header: Text("Details")) {
                    Picker("Area", selection: $selectedArea) {
                        ForEach(areas, id: \.self) { area in
                            Text(area.name ?? "Unnamed Area").tag(area as Area?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("Routine", selection: $selectedRoutine) {
                        Text("No Routine").tag(nil as Routine?)
                        ForEach(routines, id: \.self) { routine in
                            Text(routine.name ?? "Unnamed Routine").tag(routine as Routine?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label : {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        habit.area = selectedArea
                        habit.routine = selectedRoutine
                        viewModel.updateHabit(habit, name: name)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || selectedArea == nil)
                }
            }
            .onAppear {
                name = habit.name ?? ""
                selectedArea = habit.area
                selectedRoutine = habit.routine
            }
        }
    }
}
