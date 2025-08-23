//
//  HabitRowView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/22/25.
//

import SwiftUI
import CoreData

struct HabitRowView: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.name ?? "Unnamed Habit")
                    .font(.headline)
                // Example: show other properties if needed
                // Text("Created: \(habit.createdAt, formatter: dateFormatter)")
            }
            Spacer()
            // Add icons, streaks, or other elements here
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    // Provide an in-memory managed object context for preview
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let habit = Habit(context: context)
    habit.name = "Read a book"
    return HabitRowView(habit: habit)
}
