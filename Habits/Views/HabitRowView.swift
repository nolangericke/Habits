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
    let onDelete: (() -> Void)?
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingEditSheet = false

    private let haptic = UINotificationFeedbackGenerator()
    private let softHaptic = UIImpactFeedbackGenerator(style: .soft)
    
    private var streakText: String {
        let streak = HabitStreakCalculator.streak(for: habit, completions: viewModel.completions)
        return streak == 1 ? "1 day" : "\(streak) days"
    }
    
    private var progress: CGFloat {
        viewModel.isHabitCompletedToday(habit) ? 1.0 : 0.0
    }

    init(habit: Habit, onTap: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.habit = habit
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            Button(action: { onTap?() }) {
                HStack {
                    if let area = habit.area {
                        ZStack {
                            Circle()
                                .fill(Color(.tertiarySystemFill))
                                .frame(width: 44, height: 44)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 44, height: 44)
                                .animation(.easeOut(duration: 0.4), value: progress)
                            Image(systemName: area.iconName)
                                .foregroundStyle(.secondary)
                                .imageScale(.medium)
                                .fontWeight(.bold)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(habit.name ?? "Unnamed Habit")
                            .fontWeight(.medium)
                        Text(streakText)
                            .font(.footnote)
                            .foregroundStyle(streakText != "0 days" ? .accent : .secondary)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
        .sheet(isPresented: $showingEditSheet) {
            UpdateHabitView(habit: habit).environmentObject(viewModel)
        }
    }
}
