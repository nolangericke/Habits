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
            if let area = habit.area {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 44, height: 44)
                    Image(systemName: area.iconName)
                        .foregroundStyle(.secondary)
                        .imageScale(.medium)
                        .fontWeight(.bold)
                }
            }
            VStack(alignment: .leading) {
                Text(habit.name ?? "Unnamed Habit")
                    .fontWeight(.medium)
                Text("Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
