//
//  HabitRowView.swift
//  Habits
//
//  Created by Nolan Gericke on 8/22/25.
//

import SwiftUI
import CoreData
import UIKit

struct HabitRowView: View {
    let habit: Habit
    let onTap: (() -> Void)?
    @EnvironmentObject var viewModel: HabitViewModel

    private let haptic = UINotificationFeedbackGenerator()
    private let softHaptic = UIImpactFeedbackGenerator(style: .soft)

    init(habit: Habit, onTap: (() -> Void)? = nil) {
        self.habit = habit
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            Button(action: { onTap?() }) {
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
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Button {
                let wasCompleted = viewModel.isHabitCompletedToday(habit)
                viewModel.toggleHabitCompletion(habit)
                haptic.prepare()
                if wasCompleted {
                    softHaptic.impactOccurred() // unchecking = cancellation haptic
                } else {
                    haptic.notificationOccurred(.success) // checking = completion haptic
                }
            } label: {
                if viewModel.isHabitCompletedToday(habit) {
                    ZStack {
                        Image(systemName: "app.fill")
                            .imageScale(.large)
                            .foregroundStyle(.accent)
                        Image(systemName: "checkmark")
                            .imageScale(.small)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                } else {
                    Image(systemName: "app")
                        .imageScale(.large)
                        .fontWeight(.bold)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
