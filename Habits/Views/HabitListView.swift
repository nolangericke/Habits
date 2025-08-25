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
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.orderIndex, ascending: true), NSSortDescriptor(keyPath: \Habit.name, ascending: true)],
        animation: .default)
    private var habits: FetchedResults<Habit>
    
    private var habitsByRoutine: [Routine?: [Habit]] {
        Dictionary(grouping: habits) { $0.routine }
    }
    
    @State private var showingAddHabit = false
    @State private var showingAddRoutine = false
    @State private var showingReorderRoutines = false
    @State private var selectedHabit: Habit?
    
    private func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            viewModel.deleteHabit(habit)
        }
    }
    
    private func moveHabits(indices: IndexSet, newOffset: Int, habits: [Habit]) {
        var revisedHabits = habits
        revisedHabits.move(fromOffsets: indices, toOffset: newOffset)
        for (index, habit) in revisedHabits.enumerated() {
            habit.orderIndex = Int64(index)
        }
        try? context.save()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habitsByRoutine.sorted(by: { (lhs, rhs) in
                    switch (lhs.key, rhs.key) {
                    case (nil, _): return true
                    case (_, nil): return false
                    case let (l?, r?): return l.orderIndex < r.orderIndex
                    }
                }), id: \.key) { routine, habits in
                    Section(header: Text(routine?.name ?? "No Routine")) {
                        ForEach(habits, id: \.self) { habit in
                            HabitRowView(habit: habit, onTap: {
                                selectedHabit = habit
                            }, onDelete: {
                                viewModel.deleteHabit(habit)
                            })
                            .environmentObject(viewModel)
                        }
                        .onMove { indices, newOffset in
                            moveHabits(indices: indices, newOffset: newOffset, habits: habits)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingReorderRoutines = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
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
            .sheet(isPresented: $showingReorderRoutines) {
                RoutineReorderView()
                    .environmentObject(viewModel)
            }
            .navigationDestination(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
                    .environmentObject(viewModel)
            }
        }
    }
}
