//
//  HabitListView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/20/25.
//

import SwiftUI
import CoreData

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var viewModel: HabitViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.name, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<Habit>
    
    @State private var showingAddHabit = false
    @State private var showingAddRoutine = false
    @State private var selectedHabit: Habit?
    
    private func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            viewModel.deleteHabit(habit)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits, id: \.self) { habit in
                    HabitRowView(habit: habit, onTap: {
                        selectedHabit = habit
                    })
                    .environmentObject(viewModel)
                }
                .onDelete(perform: deleteHabit)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingAddRoutine) {
                AddRoutineView()
            }
            .navigationDestination(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(viewModel)
            }
        }
    }
}
