//
//  HabitListView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/20/25.
//

import SwiftUI
import CoreData

struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), style: StrokeStyle(lineWidth: lineWidth))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)
        }
        .frame(width: size, height: size)
    }
}

struct HabitListView: View {
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var viewModel: HabitViewModel
    @Environment(\.editMode) private var editMode
    
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
    
    private var todaysProgress: Double {
        let total = habits.count
        let completed = habits.filter { viewModel.isHabitCompletedToday($0) }.count
        return total > 0 ? Double(completed) / Double(total) : 0.0
    }
    
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
        // Compute allCompletedStreak here since we cannot do it at property level
        let allCompletedStreak: Int = HabitStreakCalculator.dailyStreakForAllHabits(habits: habits.map { $0 }, completions: viewModel.completions)
        
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
                    Button(action: {
                        // Optionally show a stats modal or toast here
                    }) {
                        HStack {
                            CircularProgressView(progress: todaysProgress, size: 28, lineWidth: 4)
                                .accessibilityLabel("Today's habit progress")
                                .accessibilityValue("\(Int(todaysProgress * 100)) percent complete")
                                .padding(.vertical, 2)
                            Text("\(allCompletedStreak) Days")
                                .fontWeight(.semibold)
                                .foregroundStyle(allCompletedStreak > 0 ? .accent : .secondary)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit") {
                            if editMode?.wrappedValue == .active {
                                editMode?.wrappedValue = .inactive
                            } else {
                                editMode?.wrappedValue = .active
                            }
                        }
                        Button("Reorder Routines") {
                            showingReorderRoutines = true
                        }
                        Button("Add Routine") {
                            showingAddRoutine = true
                        }
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

