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
            List(completionsForHabit, id: \.self) { completion in
                if let date = completion.date {
                    Text(date.formatted(date: .abbreviated, time: .complete))
                }
            }
        }
        .navigationTitle(habit.name ?? "Unnamed Habit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var completionsForHabit: [HabitCompletion] {
        viewModel.completions.filter { $0.habit == habit }
    }
}
