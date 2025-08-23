//
//  HabitDetailView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/23/25.
//

import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @EnvironmentObject var viewModel: HabitViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(habit.name ?? "Unnamed Habit")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            Text("Completions")
                .font(.headline)
                .padding(.bottom, 2)
            if completionsForHabit.isEmpty {
                Text("No completions yet.")
                    .foregroundStyle(.secondary)
                    .padding(.top)
            } else {
                List(completionsForHabit, id: \.self) { completion in
                    if let date = completion.date {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
            Spacer()
        }
        .padding()
    }

    private var completionsForHabit: [HabitCompletion] {
        viewModel.completions.filter { $0.habit == habit }
    }
}
